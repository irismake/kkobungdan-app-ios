//
//  OfferRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

private struct CreateOfferBody: Encodable {
  let proposalID: Int64
}

final class OfferRepository: OfferRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func createOffer(proposalID: Int64) async throws -> Offer {
    let res: ApiResponseDTO<OfferResponseDTO> = try await client.post(
      "/v1/offer",
      body: CreateOfferBody(proposalID: proposalID)
    )
    guard let dto = res.data else {
      throw RepositoryError.network
    }
    return dto.toDomain()
  }

  func fetchOffersByProposal(proposalID: Int64) async throws -> [Offer] {
    let res: ApiResponseDTO<[OfferResponseDTO]> =
      try await client.get("/v1/offer", params: ["proposalId": proposalID])
    return res.data?.map { $0.toDomain() } ?? []
  }

  func cancelOffer(offerID: Int64) async throws {
    try await client.delete("/v1/offer/\(offerID)")
  }
}
