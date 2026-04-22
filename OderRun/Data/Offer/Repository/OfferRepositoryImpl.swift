//
//  OfferRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor OfferRepositoryImpl: OfferRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  private var offers: [OfferResponseDTO] = [
    // proposal 2 (남의 proposal, OFFERED) — 러너 후보들
    .init(id: 10, proposalID: 2, runnerID: "user-r001", status: "WAITING", createdAt: "2026-04-21T11:00:00"),
    .init(id: 11, proposalID: 2, runnerID: "user-r002", status: "WAITING", createdAt: "2026-04-21T12:30:00"),
    // proposal 3 (내 proposal, OFFERED) — 내가 검토할 지원자들
    .init(id: 20, proposalID: 3, runnerID: "user-r001", status: "WAITING", createdAt: "2026-04-22T08:10:00"),
    .init(id: 21, proposalID: 3, runnerID: "user-r002", status: "WAITING", createdAt: "2026-04-22T08:45:00"),
    .init(id: 22, proposalID: 3, runnerID: "user-r003", status: "REJECTED", createdAt: "2026-04-22T09:00:00"),
    // proposal 4 (남의 proposal, MATCHED) — 확정된 offer + 거절된 offer
    .init(id: 30, proposalID: 4, runnerID: "user-r001", status: "ACCEPTED", createdAt: "2026-04-20T14:00:00"),
    .init(id: 31, proposalID: 4, runnerID: "user-r002", status: "REJECTED", createdAt: "2026-04-20T14:30:00"),
    // proposal 5 (내 proposal, MATCHED) — 내가 수락한 케이스
    .init(id: 40, proposalID: 5, runnerID: "user-r002", status: "ACCEPTED", createdAt: "2026-04-21T18:10:00"),
    .init(id: 41, proposalID: 5, runnerID: "user-r003", status: "REJECTED", createdAt: "2026-04-21T18:20:00"),
    .init(id: 42, proposalID: 5, runnerID: "user-r001", status: "CANCELLED", createdAt: "2026-04-21T17:00:00"),
    // 내가 러너로 제출한 offer 들 (me-001)
    .init(id: 50, proposalID: 1, runnerID: DummySession.currentUserID, status: "WAITING", createdAt: "2026-04-22T09:15:00"),
    .init(id: 51, proposalID: 6, runnerID: DummySession.currentUserID, status: "CANCELLED", createdAt: "2026-04-20T15:00:00")
  ]

  private var nextID: Int64 = 1000

  func createOffer(proposalID: Int64) async throws -> Offer {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let duplicated = offers.contains {
      $0.proposalID == proposalID
        && $0.runnerID == DummySession.currentUserID
        && $0.status == "WAITING"
    }
    if duplicated {
      throw RepositoryError.conflict
    }
    let newID = nextID
    nextID += 1
    let dto = OfferResponseDTO(
      id: newID,
      proposalID: proposalID,
      runnerID: DummySession.currentUserID,
      status: OfferStatus.waiting.rawValue,
      createdAt: DateFormatters.format(Date())
    )
    offers.append(dto)
    return dto.toDomain()
  }

  func fetchOffersByProposal(proposalID: Int64) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return offers
      .filter { $0.proposalID == proposalID }
      .sorted { $0.createdAt > $1.createdAt }
      .map { $0.toDomain() }
  }

  func fetchMyOffers(status: OfferStatus?, page: Int, size: Int) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let mine = offers.filter { $0.runnerID == DummySession.currentUserID }
    let filtered = status.map { status in mine.filter { $0.status == status.rawValue } } ?? mine
    let start = page * size
    guard start < filtered.count else {
      return []
    }
    let end = min(start + size, filtered.count)
    return filtered[start ..< end].map { $0.toDomain() }
  }

  func cancelOffer(offerID: Int64) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    let existing = offers[index]
    guard existing.status == "WAITING" else {
      throw RepositoryError.conflict
    }
    offers[index] = OfferResponseDTO(
      id: existing.id,
      proposalID: existing.proposalID,
      runnerID: existing.runnerID,
      status: OfferStatus.cancelled.rawValue,
      createdAt: existing.createdAt
    )
  }
}
