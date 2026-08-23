//
//  TestActivityRepositoryImpl.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/13/26.
//

import Foundation

struct TestActivityRepositoryImpl: ActivityRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  let store: DummyBackendStore

  func fetchMyProposals(
    status: [ProposalStatus],
    page: Int,
    size: Int
  ) async throws -> [MyProposal] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchMyProposals(
      userID: DummySession.currentUserID,
      status: status,
      page: page,
      size: size
    )
  }

  func fetchMyOffers(
    status: [OfferStatus],
    page: Int,
    size: Int
  ) async throws -> [MyOffer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchMyOffers(
      userID: DummySession.currentUserID,
      status: status,
      page: page,
      size: size
    )
  }
}
