//
//  OfferRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

final class OfferRepositoryImpl: OfferRepositoryProtocol, Sendable {
  func createOffer(proposalID _: Int64) async throws -> Offer {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }

  func fetchOffersByProposal(proposalID _: Int64) async throws -> [Offer] {
    // TODO: Step 4 에서 seed 채움
    []
  }

  func fetchMyOffers(status _: OfferStatus?, page _: Int, size _: Int) async throws -> [Offer] {
    // TODO: Step 4 에서 seed 채움
    []
  }

  func cancelOffer(offerID _: Int64) async throws {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }
}
