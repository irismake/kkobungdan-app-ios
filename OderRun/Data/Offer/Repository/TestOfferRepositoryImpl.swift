//
//  TestOfferRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct TestOfferRepositoryImpl: OfferRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  let store: DummyBackendStore

  func createOffer(proposalID: Int64) async throws -> Offer {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.createOffer(
      proposalID: proposalID,
      runnerID: DummySession.currentUserID
    )
  }

  func fetchOffersByProposal(proposalID: Int64) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchOffersByProposal(proposalID: proposalID)
  }

  func cancelOffer(offerID: Int64) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    try await store.cancelOffer(offerID: offerID)
  }
}
