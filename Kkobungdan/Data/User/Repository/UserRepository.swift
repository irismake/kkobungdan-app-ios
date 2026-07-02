//
//  UserRepository.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

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

  func updateName(_ name: String) async throws -> User {
    // 응답이 평문(data 없음)이라 디코드하지 않고 상태코드만 확인 후 재조회한다.
    try await client.patchVoid(
      "/v1/user/name",
      body: UserNameUpdateRequest(name: name)
    )
    return try await fetchUserDetail()
  }

  func updateAlarm(enabled: Bool) async throws -> User {
    // 응답이 `{success, message}` 평문(data 없음)이라 디코드하지 않고 상태코드만 확인 후 재조회한다.
    try await client.patchVoid(
      "/v1/user/alarm",
      body: UserAlarmRequest(alarmEnabled: enabled)
    )
    return try await fetchUserDetail()
  }

  func updateFcmToken(_ token: String) async throws {
    try await client.patchVoid(
      "/v1/user/fcm-token",
      body: UserFcmTokenRequest(fcmToken: token)
    )
  }
}
