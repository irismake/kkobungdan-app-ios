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
    let res: ApiResponseDTO<UserDetailResponseDTO> =
      try await client.get("/v1/user/detail")
    guard let dto = res.data else {
      throw RepositoryError.notFound
    }
    return dto.toDomain()
  }

  func updateAlarm(enabled: Bool) async throws -> User {
    let res: ApiResponseDTO<UserDetailResponseDTO> = try await client.post(
      "/v1/user/alarm",
      body: AlarmUpdateBody(enabled: enabled)
    )
    guard let dto = res.data else {
      throw RepositoryError.network
    }
    return dto.toDomain()
  }

  func fetchRunnerProfile(userID: String) async throws -> RunnerProfile {
    // TODO: 서버 스펙 확정 시 실제 엔드포인트로 교체. 현재는 더미 폴백.
    guard let profile = RunnerProfile.dummyByID[userID] else {
      throw RepositoryError.notFound
    }
    return profile
  }
}
