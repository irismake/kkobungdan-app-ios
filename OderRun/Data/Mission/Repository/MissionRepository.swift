//
//  MissionRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

private struct MissionActionBody: Encodable {
  let action: String
  let proofImageURL: String?
  let disputeReason: String?
}

final class MissionRepository: MissionRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchMissionByProposal(proposalID: Int64) async throws -> Mission? {
    do {
      let dto: MissionResponseDTO =
        try await client.get("/v1/mission", params: ["proposalId": proposalID])
      return dto.toDomain()
    } catch RepositoryError.notFound {
      return nil
    }
  }

  func fetchMissionByOffer(offerID: Int64) async throws -> Mission? {
    do {
      let dto: MissionResponseDTO =
        try await client.get("/v1/mission", params: ["offerId": offerID])
      return dto.toDomain()
    } catch RepositoryError.notFound {
      return nil
    }
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission {
    let dto: MissionResponseDTO = try await client.put(
      "/v1/mission/\(id)",
      body: MissionActionBody(action: action.rawValue, proofImageURL: proofImageURL, disputeReason: disputeReason)
    )
    return dto.toDomain()
  }
}
