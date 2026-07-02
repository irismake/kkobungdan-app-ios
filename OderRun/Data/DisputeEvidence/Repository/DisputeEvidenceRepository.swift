//
//  DisputeEvidenceRepository.swift
//  OderRun
//
//  Created by 김가희 on 7/2/26.
//

import Foundation

final class DisputeEvidenceRepository: DisputeEvidenceRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchEvidence(for query: DisputeEvidenceQuery) async throws -> DisputeEvidence {
    let params: [String: Any]
    switch query {
    case let .proposal(proposalID):
      params = ["proposalId": proposalID]
    case let .offer(offerID):
      params = ["offerId": offerID]
    }
    let dto: DisputeEvidenceResponseDTO = try await client.get(
      "/v1/dispute-evidence",
      params: params
    )
    return dto.toDomain()
  }
}
