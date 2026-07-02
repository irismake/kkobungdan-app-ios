//
//  OfferRepositoryProtocol.swift
//  Kkobungdan
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
  /// 제안 수락. `POST /v1/offer/{id}/accept` (무바디)
  func acceptOffer(offerID: Int64) async throws -> OfferAcceptResult
  /// 러너 배달 완료 처리. `POST /v1/offer/{id}/complete-delivery`
  func completeDelivery(offerID: Int64) async throws -> Offer
  /// 러너 분쟁 제기. `POST /v1/offer/{id}/dispute`
  func raiseDispute(offerID: Int64, surveyQuestionID: Int64, reason: String) async throws -> Offer
}
