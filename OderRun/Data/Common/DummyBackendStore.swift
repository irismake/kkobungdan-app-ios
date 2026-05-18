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
  private var offers: [Offer] = Offer.dummyList
  private var missions: [Mission] = Mission.dummyList
  private var nextProposalID: Int64 = 100
  private var nextOfferID: Int64 = 1000
  private var nextMissionID: Int64 = 1000

  // MARK: - Proposal

  func fetchProposals(page: Int, size: Int) -> [Proposal] {
    let start = page * size
    guard start < proposals.count else {
      return []
    }
    return Array(proposals[start ..< min(start + size, proposals.count)])
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
  ) -> Proposal {
    let newID = nextProposalID
    nextProposalID += 1
    let proposal = Proposal(
      id: newID,
      ordererID: ordererID,
      title: title,
      content: content,
      deadline: deadline,
      errandFee: errandFee,
      status: .posted
    )
    proposals.insert(proposal, at: 0)
    return proposal
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
      ordererID: existing.ordererID,
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

  func cancelOffer(offerID: Int64) throws {
    guard let index = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    guard offers[index].status == .waiting else {
      throw RepositoryError.conflict
    }
    offers[index] = with(offers[index], status: .cancelled)
  }

  // MARK: - Mission

  /// 미션 생성 시 같은 트랜잭션으로 선택 offer ACCEPTED, 나머지 WAITING offer REJECTED,
  /// proposal MATCHED 로 전이.
  func createMission(offerID: Int64, runFee: Int, itemPrice: Int) throws -> Mission {
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
      ordererID: proposal.ordererID,
      runnerID: offer.runnerID,
      status: .created,
      runFee: runFee,
      itemPrice: itemPrice,
      proofImageURL: nil,
      createdAt: Date()
    )
    missions.append(mission)

    acceptOfferAndRejectOthers(acceptedOfferID: offerID, proposalID: offer.proposalID)
    proposals[proposalIndex] = with(proposal, status: .matched)

    return mission
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?
  ) throws -> Mission {
    guard let index = missions.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = missions[index]
    let nextStatus: MissionStatus
    switch action {
    case .startProgress:
      guard existing.status == .created else {
        throw RepositoryError.conflict
      }
      nextStatus = .inProgress
    case .completeDelivery:
      guard existing.status == .inProgress, proofImageURL != nil else {
        throw RepositoryError.conflict
      }
      nextStatus = .deliveryCompleted
    case .confirmReceived:
      guard existing.status == .deliveryCompleted else {
        throw RepositoryError.conflict
      }
      nextStatus = .receivedConfirmed
    case .dispute:
      nextStatus = .disputed
    }
    let updated = Mission(
      id: existing.id,
      offerID: existing.offerID,
      proposalID: existing.proposalID,
      ordererID: existing.ordererID,
      runnerID: existing.runnerID,
      status: nextStatus,
      runFee: existing.runFee,
      itemPrice: existing.itemPrice,
      proofImageURL: proofImageURL ?? existing.proofImageURL,
      createdAt: existing.createdAt
    )
    missions[index] = updated
    return updated
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
    let mine = proposals.filter { $0.ordererID == userID }
    let filtered = status.map { filter in mine.filter { $0.status == filter } } ?? mine
    return paginate(filtered, page: page, size: size).map { proposal in
      MyProposal(
        id: proposal.id,
        title: proposal.title,
        content: proposal.content,
        deadline: proposal.deadline,
        meetingAt: nil,
        errandFee: proposal.errandFee,
        itemPrice: nil,
        deposit: nil,
        status: proposal.status,
        offers: offers
          .filter { $0.proposalID == proposal.id }
          .sorted { $0.createdAt > $1.createdAt }
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

  /// 미션 단위 조회. MissionDetailViewModel 처럼 proposal/offer 가 아닌 mission 상태가 필요한 곳에서 사용.
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
      ordererID: proposal.ordererID,
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
