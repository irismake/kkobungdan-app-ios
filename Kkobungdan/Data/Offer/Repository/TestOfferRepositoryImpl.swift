//
//  TestOfferRepositoryImpl.swift
//  Kkobungdan
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

  func fetchOffersByProposal(proposalID: Int64, status: [OfferStatus]) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchOffersByProposal(proposalID: proposalID, status: status)
  }

  func fetchOfferDetail(offerID: Int64) async throws -> OfferDetail {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.fetchOfferDetail(offerID: offerID)
  }

  func cancelOffer(offerID: Int64) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    try await store.cancelOffer(offerID: offerID)
  }

  func acceptOffer(offerID: Int64) async throws -> OfferAcceptResult {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.acceptOffer(offerID: offerID)
  }

  func completeDelivery(offerID: Int64) async throws -> Offer {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.completeDelivery(offerID: offerID)
  }

  func raiseDispute(offerID: Int64, reasonQuestionID: Int64, detailReason: String?) async throws -> Offer {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.raiseOfferDispute(offerID: offerID, reasonQuestionID: reasonQuestionID, detailReason: detailReason)
  }
}
