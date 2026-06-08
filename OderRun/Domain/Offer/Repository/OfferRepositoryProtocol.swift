//
//  OfferRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol OfferRepositoryProtocol: Sendable {
  func createOffer(proposalID: Int64) async throws -> Offer
  /// proposalID 의 제안 목록. `status` 다중값 필터(`status=A&status=B`), 빈 배열이면 전체 상태.
  func fetchOffersByProposal(proposalID: Int64, status: [OfferStatus]) async throws -> [Offer]
  func fetchOfferDetail(offerID: Int64) async throws -> OfferDetail
  func cancelOffer(offerID: Int64) async throws
  func acceptOffer(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> OfferAcceptResult
}
