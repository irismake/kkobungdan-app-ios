//
//  OfferRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol OfferRepositoryProtocol: Sendable {
  func createOffer(proposalID: Int64) async throws -> Offer
  func fetchOffersByProposal(proposalID: Int64) async throws -> [Offer]
  func fetchMyOffers(status: OfferStatus?, page: Int, size: Int) async throws -> [Offer]
  func cancelOffer(offerID: Int64) async throws
}
