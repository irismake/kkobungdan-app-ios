//
//  TestOfferRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor TestOfferRepositoryImpl: OfferRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  private var offers: [Offer] = Offer.dummyList
  private var nextID: Int64 = 1000

  func createOffer(proposalID: Int64) async throws -> Offer {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let duplicated = offers.contains {
      $0.proposalID == proposalID
        && $0.runnerID == DummySession.currentUserID
        && ($0.status == .waiting || $0.status == .accepted)
    }
    if duplicated {
      throw RepositoryError.conflict
    }
    let newID = nextID
    nextID += 1
    let offer = Offer(
      id: newID,
      proposalID: proposalID,
      runnerID: DummySession.currentUserID,
      status: .waiting,
      createdAt: Date()
    )
    offers.append(offer)

    // 백엔드 cascade 흉내: 첫 지원이 들어오면 proposal 을 POSTED → OFFERED 로 전이.
    if let testProposalRepo = DIContainer.proposalRepository as? TestProposalRepositoryImpl {
      await testProposalRepo.markOfferedIfPosted(id: proposalID)
    }
    return offer
  }

  func fetchOffersByProposal(proposalID: Int64) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return offers
      .filter { $0.proposalID == proposalID }
      .sorted { $0.createdAt > $1.createdAt }
  }

  func fetchMyOffers(status: OfferStatus?, page: Int, size: Int) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let mine = offers.filter { $0.runnerID == DummySession.currentUserID }
    let filtered = status.map { status in mine.filter { $0.status == status } } ?? mine
    let start = page * size
    guard start < filtered.count else {
      return []
    }
    return Array(filtered[start ..< min(start + size, filtered.count)])
  }

  func cancelOffer(offerID: Int64) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    guard offers[index].status == .waiting else {
      throw RepositoryError.conflict
    }
    let existing = offers[index]
    offers[index] = Offer(
      id: existing.id,
      proposalID: existing.proposalID,
      runnerID: existing.runnerID,
      status: .cancelled,
      createdAt: existing.createdAt
    )
  }

  /// 더미 환경에서 proposal 취소 시 백엔드 cascade 를 흉내내기 위한 헬퍼.
  /// 해당 proposal 의 WAITING/ACCEPTED offer 를 모두 REJECTED 로 전환한다.
  func applyProposalCancelCascade(proposalID: Int64) {
    for index in offers.indices where offers[index].proposalID == proposalID {
      let existing = offers[index]
      guard existing.status == .waiting || existing.status == .accepted else {
        continue
      }
      offers[index] = Offer(
        id: existing.id,
        proposalID: existing.proposalID,
        runnerID: existing.runnerID,
        status: .rejected,
        createdAt: existing.createdAt
      )
    }
  }

  /// 더미 환경에서 미션 생성 시 백엔드 cascade 를 흉내내기 위한 헬퍼.
  /// 선택된 offer 는 ACCEPTED, 같은 proposal 의 다른 WAITING offer 는 REJECTED 로 전환한다.
  func applyMissionCreationCascade(acceptedOfferID: Int64, proposalID: Int64) {
    for index in offers.indices where offers[index].proposalID == proposalID {
      let existing = offers[index]
      let nextStatus: OfferStatus
      if existing.id == acceptedOfferID {
        nextStatus = .accepted
      } else if existing.status == .waiting {
        nextStatus = .rejected
      } else {
        continue
      }
      offers[index] = Offer(
        id: existing.id,
        proposalID: existing.proposalID,
        runnerID: existing.runnerID,
        status: nextStatus,
        createdAt: existing.createdAt
      )
    }
  }

  func offerStatus(offerID: Int64) -> OfferStatus? {
    offers.first(where: { $0.id == offerID })?.status
  }
}
