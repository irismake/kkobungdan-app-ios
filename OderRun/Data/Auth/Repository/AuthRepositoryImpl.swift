//
//  AuthRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol, Sendable {
  func signup(email _: String, password _: String, name _: String, phone _: String) async throws {
    // TODO: 실제 API 연동 시 구현 (Step 4 에서 더미 seed 채움)
    throw RepositoryError.notImplemented
  }

  func login(email _: String, password _: String) async throws -> AuthTokens {
    // TODO: 실제 API 연동 시 구현 (Step 4 에서 더미 seed 채움)
    throw RepositoryError.notImplemented
  }

  func refresh(refreshToken _: String) async throws -> AuthTokens {
    // TODO: 실제 API 연동 시 구현 (Step 4 에서 더미 seed 채움)
    throw RepositoryError.notImplemented
  }

  func logout(refreshToken _: String) async throws {
    // TODO: 실제 API 연동 시 구현 (Step 4 에서 더미 seed 채움)
    throw RepositoryError.notImplemented
  }
}

enum AuthError: Error {
  case invalidCredentials
  case networkError
}
