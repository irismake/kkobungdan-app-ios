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

  func fetchMyMissions(
    role: MissionRole,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission] {
    var params: [String: Any] = ["role": role.rawValue, "page": page, "size": size]
    if let status {
      params["status"] = status.rawValue
    }
    let res: ApiResponseDTO<PageDTO<MissionResponseDTO>> =
      try await client.get("/v1/mission/own", params: params)
    return res.data?.content.map { $0.toDomain() } ?? []
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
