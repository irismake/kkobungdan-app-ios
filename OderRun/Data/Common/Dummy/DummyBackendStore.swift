//
//  DummyBackendStore.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  더미 환경에서 실제 백엔드의 단일 DB + 트랜잭션 cascade 를 흉내내는 인메모리 저장소.
//  proposal / offer 데이터가 한 actor 안에서 관리되어, 상태 전이가
//  여러 Test*RepositoryImpl 로 흩어지지 않고 이 곳에 모인다.
//

import Foundation

actor DummyBackendStore {
  private var proposals: [Proposal] = Proposal.dummyList
  private var ordererIDByProposalID: [Int64: String] = Proposal.dummyOrdererIDByProposalID
  private var offers: [Offer] = Offer.dummyList
  private var nextProposalID: Int64 = 100
  private var nextOfferID: Int64 = 1000

  // MARK: - Proposal

  /// 홈 피드용 proposal 목록. `status` 가 비어 있으면 아직 의뢰자가 수락하지 않아 다른 러너가
  /// 지원할 수 있는 활성 상태(`.posted` = 등록 완료·지원 대기 / `.offered` = 새로운 지원 도착)만
  /// 반환하고, 지정되면 해당 상태들로 필터한다.
  func fetchProposals(status: [ProposalStatus], page: Int, size: Int) -> [Proposal] {
    let filtered: [Proposal]
    if status.isEmpty {
      filtered = proposals.filter {
        $0.status == .posted || $0.status == .offered
      }
    } else {
      filtered = proposals.filter { status.contains($0.status) }
    }
    return paginate(filtered, page: page, size: size)
  }

  func fetchProposal(id: Int64) throws -> ProposalDetail {
    guard let proposal = proposals.first(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    return detail(proposal)
  }

  /// 내부 저장 타입 Proposal → 상세 응답 엔티티 ProposalDetail. 요청자 레벨은 ordererID 로 채운다.
  private func detail(_ proposal: Proposal) -> ProposalDetail {
    let ordererID = ordererIDByProposalID[proposal.id] ?? ""
    return ProposalDetail(
      id: proposal.id,
      title: proposal.title,
      content: proposal.content,
      deadline: proposal.deadline,
      errandFee: proposal.errandFee,
      status: proposal.status,
      ordererID: ordererID,
      ordererName: DummySession.displayName(for: ordererID),
      ordererLevel: DummySession.level(for: ordererID)
    )
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
    return stub
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

  /// 오더러 수령 확인. `POST /v1/proposal/{id}/confirm-received`
  /// 러너가 이미 완료(RUNNER_COMPLETED)했으면 양측 정산(ALL_COMPLETED), 아니면 ORDER_COMPLETED.
  func confirmReceived(proposalID: Int64) throws -> ProposalDetail {
    guard let proposalIndex = proposals.firstIndex(where: { $0.id == proposalID }) else {
      throw RepositoryError.notFound
    }
    let proposal = proposals[proposalIndex]
    guard proposal.status == .matched else {
      throw RepositoryError.conflict
    }
    if let offerIndex = offers.firstIndex(where: {
      $0.proposalID == proposalID && $0.status == .runnerCompleted
    }) {
      offers[offerIndex] = with(offers[offerIndex], status: .allCompleted)
      let done = with(proposal, status: .allCompleted)
      proposals[proposalIndex] = done
      return detail(done)
    }
    let updated = with(proposal, status: .orderCompleted)
    proposals[proposalIndex] = updated
    return detail(updated)
  }

  /// 오더러 분쟁 제기. `POST /v1/proposal/{id}/dispute`
  func raiseProposalDispute(proposalID: Int64, reason _: String) throws -> ProposalDetail {
    guard let proposalIndex = proposals.firstIndex(where: { $0.id == proposalID }) else {
      throw RepositoryError.notFound
    }
    let updated = with(proposals[proposalIndex], status: .disputed)
    proposals[proposalIndex] = updated
    if let offerIndex = offers.firstIndex(where: {
      $0.proposalID == proposalID && ($0.status == .accepted || $0.status == .runnerCompleted)
    }) {
      offers[offerIndex] = with(offers[offerIndex], status: .disputed)
    }
    return detail(updated)
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
      runnerName: DummySession.displayName(for: runnerID),
      runnerLevel: DummySession.level(for: runnerID),
      status: .waiting,
      createdAt: Date()
    )
    offers.append(offer)
    promoteToOfferedIfNeeded(proposalID: proposalID)
    return offer
  }

  func fetchOffersByProposal(proposalID: Int64, status: [OfferStatus]) -> [Offer] {
    offers
      .filter { $0.proposalID == proposalID && (status.isEmpty || status.contains($0.status)) }
      .sorted { $0.createdAt > $1.createdAt }
  }

  /// `GET /v1/offer/{offerId}` 인메모리 흉내.
  func fetchOfferDetail(offerID: Int64) throws -> OfferDetail {
    guard let offer = offers.first(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    return OfferDetail(
      id: offer.id,
      proposalID: offer.proposalID,
      runnerID: offer.runnerID,
      runnerName: offer.runnerName,
      status: offer.status,
      createdAt: offer.createdAt
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
  /// offer ACCEPTED, 같은 proposal 의 나머지 WAITING offer REJECTED, proposal MATCHED 로 전이.
  func acceptOffer(offerID: Int64) throws -> OfferAcceptResult {
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

    let rejectedCount = acceptOfferAndRejectOthers(acceptedOfferID: offerID, proposalID: offer.proposalID)
    let matched = with(proposal, status: .matched)
    proposals[proposalIndex] = matched

    return OfferAcceptResult(
      proposalID: matched.id,
      offerID: offerID,
      proposalStatus: .matched,
      acceptedOfferStatus: .accepted,
      rejectedOfferCount: rejectedCount,
      ordererID: ordererIDByProposalID[proposal.id] ?? "",
      runnerID: offer.runnerID,
      acceptedAt: Date()
    )
  }

  /// 러너 배달 완료. `POST /v1/offer/{id}/complete-delivery`
  /// 오더러가 이미 수령 확인(ORDER_COMPLETED)했으면 양측 정산(ALL_COMPLETED), 아니면 RUNNER_COMPLETED.
  func completeDelivery(offerID: Int64, proofImageURL _: String?) throws -> Offer {
    guard let offerIndex = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    let offer = offers[offerIndex]
    guard offer.status == .accepted else {
      throw RepositoryError.conflict
    }
    guard let proposalIndex = proposals.firstIndex(where: { $0.id == offer.proposalID }) else {
      throw RepositoryError.notFound
    }
    let proposal = proposals[proposalIndex]
    if proposal.status == .orderCompleted {
      let done = with(offer, status: .allCompleted)
      offers[offerIndex] = done
      proposals[proposalIndex] = with(proposal, status: .allCompleted)
      return done
    }
    let updated = with(offer, status: .runnerCompleted)
    offers[offerIndex] = updated
    return updated
  }

  /// 러너 분쟁 제기. `POST /v1/offer/{id}/dispute`
  func raiseOfferDispute(offerID: Int64, reason _: String) throws -> Offer {
    guard let offerIndex = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    let updated = with(offers[offerIndex], status: .disputed)
    offers[offerIndex] = updated
    if let proposalIndex = proposals.firstIndex(where: { $0.id == updated.proposalID }) {
      proposals[proposalIndex] = with(proposals[proposalIndex], status: .disputed)
    }
    return updated
  }

  // MARK: - Activity

  /// 내 proposal 활동. /v1/proposal/own 의 인메모리 흉내.
  func fetchMyProposals(
    userID: String,
    status: [ProposalStatus],
    page: Int,
    size: Int
  ) -> [MyProposal] {
    let mine = proposals.filter { ordererIDByProposalID[$0.id] == userID }
    let filtered = status.isEmpty ? mine : mine.filter { status.contains($0.status) }
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
  func fetchMyOffers(
    userID: String,
    status: [OfferStatus],
    page: Int,
    size: Int
  ) -> [MyOffer] {
    let mine = offers.filter { $0.runnerID == userID }
    let filtered = status.isEmpty ? mine : mine.filter { status.contains($0.status) }
    return paginate(filtered, page: page, size: size).map { offer in
      MyOffer(
        id: offer.id,
        proposalID: offer.proposalID,
        runnerID: offer.runnerID,
        status: offer.status,
        createdAt: offer.createdAt
      )
    }
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
    status == .holding || status == .posted || status == .offered
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
    guard proposal.status == .posted else {
      return
    }
    proposals[index] = with(proposal, status: .offered)
  }

  private func acceptOfferAndRejectOthers(acceptedOfferID: Int64, proposalID: Int64) -> Int {
    var rejectedCount = 0
    for index in offers.indices where offers[index].proposalID == proposalID {
      let offer = offers[index]
      if offer.id == acceptedOfferID {
        offers[index] = with(offer, status: .accepted)
      } else if offer.status == .waiting {
        offers[index] = with(offer, status: .rejected)
        rejectedCount += 1
      }
    }
    return rejectedCount
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
      runnerName: offer.runnerName,
      runnerLevel: offer.runnerLevel,
      status: status,
      createdAt: offer.createdAt
    )
  }
}
