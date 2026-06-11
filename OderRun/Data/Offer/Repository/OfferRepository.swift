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
    let dtos: [OfferResponseDTO] =
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
    let dto: OfferDeliveryResponseDTO = try await client.post(
      "/v1/offer/\(offerID)/complete-delivery",
      body: ProofDeliveryRequest(proofImageUrl: proofImageURL)
    )
    return dto.toDomain()
  }

  func raiseDispute(offerID: Int64, reason: String) async throws -> Offer {
    let dto: OfferDisputeResponseDTO = try await client.post(
      "/v1/offer/\(offerID)/dispute",
      body: ProofDisputeRequest(disputeReason: reason)
    )
    return dto.toDomain()
  }
}
