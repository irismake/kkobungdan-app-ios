//
//  ActivityRepository.swift
//  OderRun
//
//  Created by 김가희 on 5/13/26.
//

import Foundation

final class ActivityRepository: ActivityRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchMyActivities(
    role: MissionRole?,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission] {
    var params: [String: Any] = ["page": page, "size": size]
    if let role {
      params["role"] = role.rawValue
    }
    if let status {
      params["status"] = status.rawValue
    }
    let res: ApiResponseDTO<PageDTO<MissionResponseDTO>> =
      try await client.get("/v1/activity", params: params)
    return res.data?.content.map { $0.toDomain() } ?? []
  }
}
