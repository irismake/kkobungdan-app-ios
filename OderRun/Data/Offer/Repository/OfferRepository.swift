//
//  OfferRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

private struct CreateOfferBody: Encodable {
  let proposalID: Int64

  enum CodingKeys: String, CodingKey {
    case proposalID = "proposalId"
  }
}

/// `POST /v1/offer/{id}/complete-delivery` 요청 바디. proofImageUrl 은 서버 optional. (서버: `ProofDeliveryRequest`)
private struct ProofDeliveryRequest: Encodable {
  let proofImageUrl: String?
}

/// `POST /v1/offer/{id}/dispute` 요청 바디. disputeReason 은 서버 required. (서버: `DisputeRequest`)
private struct DisputeRequest: Encodable {
  // TODO: surveyQuestionID — 분쟁 설문 UI 연동 전까지 stub 값 전송
  let surveyQuestionID: Int = DisputeRequest.stubSurveyQuestionID
  let disputeReason: String

  enum CodingKeys: String, CodingKey {
    case surveyQuestionID = "surveyQuestionId"
    case disputeReason
  }

  // TODO: surveyQuestionID UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubSurveyQuestionID: Int = 0
}

final class OfferRepository: OfferRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func createOffer(proposalID: Int64) async throws -> Offer {
    let dto: OfferResponseDTO = try await client.post(
      "/v1/offer",
      body: CreateOfferBody(proposalID: proposalID)
    )
    return dto.toDomain()
  }

  func fetchOffersByProposal(proposalID: Int64, status: [OfferStatus]) async throws -> [Offer] {
    var params: [String: Any] = ["proposalId": proposalID]
    if !status.isEmpty {
      params["status"] = status.map(\.rawValue)
    }
    let dtos: [OfferSummaryResponseDTO] =
      try await client.get("/v1/offer", params: params)
    return dtos.map { $0.toDomain() }
  }

  func fetchOfferDetail(offerID: Int64) async throws -> OfferDetail {
    let dto: OfferDetailResponseDTO =
      try await client.get("/v1/offer/\(offerID)")
    return dto.toDomain()
  }

  func cancelOffer(offerID: Int64) async throws {
    try await client.delete("/v1/offer/\(offerID)")
  }

  /// 제안 수락. 무바디 POST 로 proposal/offer cascade 가 서버에서 처리된다.
  func acceptOffer(offerID: Int64) async throws -> OfferAcceptResult {
    let dto: OfferAcceptResponseDTO = try await client.post(
      "/v1/offer/\(offerID)/accept",
      body: nil as String?
    )
    return dto.toDomain()
  }

  func completeDelivery(offerID: Int64, proofImageURL: String?) async throws -> Offer {
    // complete-delivery·dispute 모두 OfferResponse 를 반환한다.
    let dto: OfferResponseDTO = try await client.post(
      "/v1/offer/\(offerID)/complete-delivery",
      body: ProofDeliveryRequest(proofImageUrl: proofImageURL)
    )
    return dto.toDomain()
  }

  func raiseDispute(offerID: Int64, reason: String) async throws -> Offer {
    let dto: OfferResponseDTO = try await client.post(
      "/v1/offer/\(offerID)/dispute",
      body: DisputeRequest(disputeReason: reason)
    )
    return dto.toDomain()
  }
}
