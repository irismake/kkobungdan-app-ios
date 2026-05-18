//
//  MissionRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

private struct CreateMissionBody: Encodable {
  let offerID: Int64
  let runFee: Int
  let itemPrice: Int
}

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

  func createMission(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> Mission {
    let res: ApiResponseDTO<MissionResponseDTO> = try await client.post(
      "/v1/mission",
      body: CreateMissionBody(offerID: offerID, runFee: runFee, itemPrice: itemPrice)
    )
    guard let dto = res.data else {
      throw RepositoryError.network
    }
    return dto.toDomain()
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission {
    let res: ApiResponseDTO<MissionResponseDTO> = try await client.put(
      "/v1/mission/\(id)",
      body: MissionActionBody(action: action.rawValue, proofImageURL: proofImageURL, disputeReason: disputeReason)
    )
    guard let dto = res.data else {
      throw RepositoryError.network
    }
    return dto.toDomain()
  }
}
