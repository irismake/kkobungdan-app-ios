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
  func fetchOfferDetail(offerID: Int64) async throws -> OfferDetail
  func cancelOffer(offerID: Int64) async throws
  func acceptOffer(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> MyProposal
}
