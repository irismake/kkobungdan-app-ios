//
//  UserRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

private struct AlarmUpdateBody: Encodable {
  let enabled: Bool
}

final class UserRepository: UserRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchUserDetail() async throws -> User {
    let dto: UserDetailResponseDTO =
      try await client.get("/v1/user/detail")
    return dto.toDomain()
  }

  func updateAlarm(enabled: Bool) async throws -> User {
    let dto: UserDetailResponseDTO = try await client.post(
      "/v1/user/alarm",
      body: AlarmUpdateBody(enabled: enabled)
    )
    return dto.toDomain()
  }

  func fetchRunner(id: String) async throws -> RunnerProfile {
    let dto: RunnerProfileResponseDTO = try await client.get("/v1/user/\(id)")
    return dto.toDomain()
  }
}
