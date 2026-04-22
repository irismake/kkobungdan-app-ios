//
//  AuthRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

actor AuthRepositoryImpl: AuthRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 800_000_000

  func signup(email: String, password: String, name: String, phone: String) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !phone.isEmpty else {
      throw RepositoryError.unauthorized
    }
    if email == "conflict@test.com" {
      throw RepositoryError.conflict
    }
  }

  func login(email: String, password: String) async throws -> AuthTokens {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard !email.isEmpty, !password.isEmpty, email != "fail@test.com" else {
      throw RepositoryError.unauthorized
    }
    let dto = LoginResponseDTO(
      accessToken: DummySession.accessToken,
      refreshToken: DummySession.refreshToken
    )
    return dto.toDomain()
  }

  func refresh(refreshToken: String) async throws -> AuthTokens {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard refreshToken == DummySession.refreshToken else {
      throw RepositoryError.unauthorized
    }
    let dto = LoginResponseDTO(
      accessToken: DummySession.accessToken,
      refreshToken: DummySession.refreshToken
    )
    return dto.toDomain()
  }

  func logout(refreshToken _: String) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
  }
}
