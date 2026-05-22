//
//  DummyBackendStore.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  더미 환경에서 실제 백엔드의 단일 DB + 트랜잭션 cascade 를 흉내내는 인메모리 저장소.
//  proposal / offer / mission 데이터가 한 actor 안에서 관리되어, 상태 전이가
//  여러 Test*RepositoryImpl 로 흩어지지 않고 이 곳에 모인다.
//

import Foundation

actor DummyBackendStore {
  private var proposals: [Proposal] = Proposal.dummyList
  private var ordererIDByProposalID: [Int64: String] = Proposal.dummyOrdererIDByProposalID
  private var offers: [Offer] = Offer.dummyList
  private var missions: [Mission] = Mission.dummyList
  private var nextProposalID: Int64 = 100
  private var nextOfferID: Int64 = 1000
  private var nextMissionID: Int64 = 1000

  // MARK: - Proposal

  /// 홈 피드용 proposal 목록. 서버는 아직 의뢰자가 수락하지 않아 다른 러너가 지원할 수 있는
  /// 활성 상태(`.waiting` = 대기중 / `.offered` = 새로운 지원 도착)만 반환한다.
  func fetchProposals(page: Int, size: Int) -> [Proposal] {
    let filtered = proposals.filter { $0.status == .waiting || $0.status == .offered }
    return paginate(filtered, page: page, size: size)
  }

  func fetchProposal(id: Int64) throws -> Proposal {
    guard let proposal = proposals.first(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    return proposal
  }

  func createProposal(
    ordererID: String,
    title: String,
    content: String,
    deadline: Date,
    errandFee: Int
  ) -> ProposalDetail {
    let newID = nextProposalID
    nextProposalID += 1
    let stub = Proposal(
      id: newID,
      title: title,
      content: content,
      deadline: deadline,
      errandFee: errandFee,
      status: .holding
    )
    ordererIDByProposalID[newID] = ordererID
    proposals.insert(stub, at: 0)
    // TODO: 서버에서 meetingAt/itemPrice/deposit 필드 제거되면 ProposalDetail에서도 삭제
    return ProposalDetail(
      id: newID,
      title: title,
      content: content,
      deadline: deadline,
      meetingAt: deadline,
      errandFee: errandFee,
      itemPrice: 1000,
      deposit: 1000,
      status: .holding
    )
  }

  func updateProposal(
    id: Int64,
    title: String,
    content: String,
    deadline: Date,
    errandFee: Int?
  ) throws -> Proposal {
    guard let index = proposals.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = proposals[index]
    guard canEditOrCancel(existing.status) else {
      throw RepositoryError.conflict
    }
    let updated = Proposal(
      id: existing.id,
      title: title,
      content: content,
      deadline: deadline,
      errandFee: errandFee ?? existing.errandFee,
      status: existing.status
    )
    proposals[index] = updated
    return updated
  }

  /// proposal 취소 시 관련 WAITING/ACCEPTED offer 도 같은 트랜잭션으로 REJECTED 전이.
  func cancelProposal(id: Int64) throws -> Proposal {
    guard let index = proposals.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = proposals[index]
    guard canEditOrCancel(existing.status) else {
      throw RepositoryError.conflict
    }
    let cancelled = with(existing, status: .cancelled)
    proposals[index] = cancelled
    rejectActiveOffers(forProposalID: id)
    return cancelled
  }

  // MARK: - Offer

  /// 첫 offer 면 proposal POSTED/WAITING → OFFERED 로 같이 전이.
  func createOffer(proposalID: Int64, runnerID: String) throws -> Offer {
    let duplicated = offers.contains {
      $0.proposalID == proposalID
        && $0.runnerID == runnerID
        && ($0.status == .waiting || $0.status == .accepted)
    }
    if duplicated {
      throw RepositoryError.conflict
    }
    let newID = nextOfferID
    nextOfferID += 1
    let offer = Offer(
      id: newID,
      proposalID: proposalID,
      runnerID: runnerID,
      status: .waiting,
      createdAt: Date()
    )
    offers.append(offer)
    promoteToOfferedIfNeeded(proposalID: proposalID)
    return offer
  }

  func fetchOffersByProposal(proposalID: Int64) -> [Offer] {
    offers
      .filter { $0.proposalID == proposalID }
      .sorted { $0.createdAt > $1.createdAt }
  }

  /// `GET /v1/offer/{offerId}` 인메모리 흉내. offer 기본 필드 + 러너 프로필을 함께 반환.
  func fetchOfferDetail(offerID: Int64) throws -> OfferDetail {
    guard let offer = offers.first(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    let profile = OfferDetail.dummyProfile(for: offer.runnerID)
    return OfferDetail(
      id: offer.id,
      proposalID: offer.proposalID,
      runnerID: offer.runnerID,
      status: offer.status,
      createdAt: offer.createdAt,
      nickname: profile.nickname,
      level: profile.level,
      grade: profile.grade
    )
  }

  func cancelOffer(offerID: Int64) throws {
    guard let index = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    guard offers[index].status == .waiting else {
      throw RepositoryError.conflict
    }
    offers[index] = with(offers[index], status: .cancelled)
  }

  /// `POST /v1/offer/{offerId}/accept` 의 인메모리 흉내.
  /// offer ACCEPTED, 같은 proposal 의 나머지 WAITING offer REJECTED, proposal MATCHED 로 전이하고
  /// 미션을 생성한다. 응답은 매칭된 proposal 정보(MyProposal) 그대로 반환.
  func acceptOffer(offerID: Int64, runFee: Int, itemPrice: Int) throws -> MyProposal {
    if missions.contains(where: { $0.offerID == offerID }) {
      throw RepositoryError.conflict
    }
    guard let offerIndex = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    let offer = offers[offerIndex]
    guard offer.status == .waiting else {
      throw RepositoryError.conflict
    }
    guard let proposalIndex = proposals.firstIndex(where: { $0.id == offer.proposalID }) else {
      throw RepositoryError.notFound
    }
    let proposal = proposals[proposalIndex]
    guard proposal.status == .offered else {
      throw RepositoryError.conflict
    }

    let newID = nextMissionID
    nextMissionID += 1
    let mission = Mission(
      id: newID,
      offerID: offerID,
      proposalID: offer.proposalID,
      ordererID: ordererIDByProposalID[proposal.id] ?? "",
      runnerID: offer.runnerID,
      status: .created,
      runFee: runFee,
      itemPrice: itemPrice,
      proofImageURL: nil,
      createdAt: Date()
    )
    missions.append(mission)

    acceptOfferAndRejectOthers(acceptedOfferID: offerID, proposalID: offer.proposalID)
    let matched = with(proposal, status: .matched)
    proposals[proposalIndex] = matched

    return MyProposal(
      id: matched.id,
      title: matched.title,
      content: matched.content,
      deadline: matched.deadline,
      errandFee: matched.errandFee,
      status: matched.status
    )
  }

  // MARK: - Mission

  /// proposal 에 매칭된 미션 1건. accept 시 cascade 로 1개만 만들어지므로 첫 매치를 반환.
  func fetchMission(proposalID: Int64) -> Mission? {
    missions.first(where: { $0.proposalID == proposalID })
  }

  /// 수락된 offer 로 생성된 미션 1건.
  func fetchMission(offerID: Int64) -> Mission? {
    missions.first(where: { $0.offerID == offerID })
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) throws -> Mission {
    guard let index = missions.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = missions[index]

    switch action {
    case .startProgress:
      guard existing.status == .created else {
        throw RepositoryError.conflict
      }
      let updated = with(existing, status: .inProgress, proofImageURL: proofImageURL)
      missions[index] = updated
      return updated

    case .completeDelivery:
      guard let proofImageURL, !proofImageURL.isEmpty else {
        throw RepositoryError.conflict
      }
      switch existing.status {
      case .created, .inProgress:
        let updated = with(existing, status: .deliveryCompleted, proofImageURL: proofImageURL)
        missions[index] = updated
        return updated
      case .receivedConfirmed:
        return try completeMissionCascade(
          at: index,
          mission: with(existing, status: .settled, proofImageURL: proofImageURL)
        )
      default:
        throw RepositoryError.conflict
      }

    case .confirmReceived:
      switch existing.status {
      case .created, .inProgress:
        let updated = with(existing, status: .receivedConfirmed, proofImageURL: proofImageURL)
        missions[index] = updated
        return updated
      case .deliveryCompleted:
        return try completeMissionCascade(
          at: index,
          mission: with(existing, status: .settled, proofImageURL: proofImageURL)
        )
      default:
        throw RepositoryError.conflict
      }

    case .dispute:
      guard let disputeReason, !disputeReason.isEmpty else {
        throw RepositoryError.conflict
      }
      let updated = with(existing, status: .disputed, proofImageURL: proofImageURL)
      missions[index] = updated
      return updated
    }
  }

  private func completeMissionCascade(at index: Int, mission: Mission) throws -> Mission {
    missions[index] = mission
    if let offerIndex = offers.firstIndex(where: { $0.id == mission.offerID }) {
      offers[offerIndex] = with(offers[offerIndex], status: .complete)
    }
    if let proposalIndex = proposals.firstIndex(where: { $0.id == mission.proposalID }) {
      proposals[proposalIndex] = with(proposals[proposalIndex], status: .complete)
    }
    return mission
  }

  private func with(_ mission: Mission, status: MissionStatus, proofImageURL: String?) -> Mission {
    Mission(
      id: mission.id,
      offerID: mission.offerID,
      proposalID: mission.proposalID,
      ordererID: mission.ordererID,
      runnerID: mission.runnerID,
      status: status,
      runFee: mission.runFee,
      itemPrice: mission.itemPrice,
      proofImageURL: proofImageURL ?? mission.proofImageURL,
      createdAt: mission.createdAt
    )
  }

  // MARK: - Activity

  /// 내 proposal 활동. /v1/proposal/own 의 인메모리 흉내.
  /// 각 MyProposal 에는 그 proposal 에 달린 offer 목록이 함께 포함된다.
  func fetchMyProposals(
    userID: String,
    status: ProposalStatus?,
    page: Int,
    size: Int
  ) -> [MyProposal] {
    let mine = proposals.filter { ordererIDByProposalID[$0.id] == userID }
    let filtered = status.map { filter in mine.filter { $0.status == filter } } ?? mine
    return paginate(filtered, page: page, size: size).map { proposal in
      MyProposal(
        id: proposal.id,
        title: proposal.title,
        content: proposal.content,
        deadline: proposal.deadline,
        errandFee: proposal.errandFee,
        status: proposal.status
      )
    }
  }

  /// 내 offer 활동. /v1/offer/own 의 인메모리 흉내.
  /// 응답에 proposal 정보(title 등)가 함께 내려오는 모양을 따라 join 결과를 반환한다.
  func fetchMyOffers(
    userID: String,
    status: OfferStatus?,
    page: Int,
    size: Int
  ) -> [MyOffer] {
    let mine = offers.filter { $0.runnerID == userID }
    let filtered = status.map { filter in mine.filter { $0.status == filter } } ?? mine
    return paginate(filtered, page: page, size: size).compactMap { offer -> MyOffer? in
      guard let proposal = proposals.first(where: { $0.id == offer.proposalID }) else {
        return nil
      }
      return MyOffer(
        id: offer.id,
        proposalID: proposal.id,
        title: proposal.title,
        content: proposal.content,
        deadline: proposal.deadline,
        meetingAt: nil,
        errandFee: proposal.errandFee,
        itemPrice: nil,
        deposit: nil,
        status: offer.status
      )
    }
  }

  /// 미션 단위 목록 조회. `/v1/mission/own` 의 인메모리 흉내.
  func fetchMyMissions(
    userID: String,
    role: MissionRole,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) -> [Mission] {
    let mine = missions.filter {
      switch role {
      case .orderer: return $0.ordererID == userID
      case .runner: return $0.runnerID == userID
      }
    }
    let filtered = status.map { status in mine.filter { $0.status == status } } ?? mine
    return paginate(filtered, page: page, size: size)
  }

  private func paginate<T>(_ items: [T], page: Int, size: Int) -> [T] {
    let start = page * size
    guard start < items.count else {
      return []
    }
    return Array(items[start ..< min(start + size, items.count)])
  }

  // MARK: - Private cascade helpers

  private func canEditOrCancel(_ status: ProposalStatus) -> Bool {
    status == .posted || status == .waiting || status == .offered
  }

  private func rejectActiveOffers(forProposalID proposalID: Int64) {
    for index in offers.indices where offers[index].proposalID == proposalID {
      let offer = offers[index]
      guard offer.status == .waiting || offer.status == .accepted else {
        continue
      }
      offers[index] = with(offer, status: .rejected)
    }
  }

  private func promoteToOfferedIfNeeded(proposalID: Int64) {
    guard let index = proposals.firstIndex(where: { $0.id == proposalID }) else {
      return
    }
    let proposal = proposals[index]
    guard proposal.status == .posted || proposal.status == .waiting else {
      return
    }
    proposals[index] = with(proposal, status: .offered)
  }

  private func acceptOfferAndRejectOthers(acceptedOfferID: Int64, proposalID: Int64) {
    for index in offers.indices where offers[index].proposalID == proposalID {
      let offer = offers[index]
      if offer.id == acceptedOfferID {
        offers[index] = with(offer, status: .accepted)
      } else if offer.status == .waiting {
        offers[index] = with(offer, status: .rejected)
      }
    }
  }

  private func with(_ proposal: Proposal, status: ProposalStatus) -> Proposal {
    Proposal(
      id: proposal.id,
      title: proposal.title,
      content: proposal.content,
      deadline: proposal.deadline,
      errandFee: proposal.errandFee,
      status: status
    )
  }

  private func with(_ offer: Offer, status: OfferStatus) -> Offer {
    Offer(
      id: offer.id,
      proposalID: offer.proposalID,
      runnerID: offer.runnerID,
      status: status,
      createdAt: offer.createdAt
    )
  }
}
