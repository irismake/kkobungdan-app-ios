//
//  AuthRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol, Sendable {
  func login(email: String, password: String) async throws -> User {
    // TODO: 실제 API 연동 시 구현
    try await Task.sleep(nanoseconds: 1_000_000_000)

    if email.isEmpty || password.isEmpty {
      throw AuthError.invalidCredentials
    }

    // TODO: 실제 서버 응답으로 교체
    let dto = UserResponseDTO(
      id: "temp-user-id",
      email: email,
      name: "홍길동",
      phone: "010-1234-5678",
      createdAt: "2026-01-01T10:00:00",
      lastLoginAt: "2026-03-10T12:00:00"
    )

    return dto.toDomain()
  }
}

enum AuthError: Error {
  case invalidCredentials
  case networkError
}
