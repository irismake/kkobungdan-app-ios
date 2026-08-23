//
//  ActivityRepository.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/13/26.
//

import Foundation

final class ActivityRepository: ActivityRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchMyProposals(
    status: [ProposalStatus],
    page: Int,
    size: Int
  ) async throws -> [MyProposal] {
    var params: [String: Any] = ["page": page, "size": size]
    if !status.isEmpty {
      params["status"] = status.map(\.rawValue)
    }
    let pageDTO: PageDTO<MyProposalResponseDTO> =
      try await client.get("/v1/proposal/own", params: params)
    return pageDTO.content.map { $0.toDomain() }
  }

  func fetchMyOffers(
    status: [OfferStatus],
    page: Int,
    size: Int
  ) async throws -> [MyOffer] {
    var params: [String: Any] = ["page": page, "size": size]
    if !status.isEmpty {
      params["status"] = status.map(\.rawValue)
    }
    let pageDTO: PageDTO<OfferResponseDTO> =
      try await client.get("/v1/offer/own", params: params)
    return pageDTO.content.map { $0.toDomain() }
  }
}
