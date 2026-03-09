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
    return User(id: UUID().uuidString, email: email, name: nil)
  }
}

enum AuthError: Error {
  case invalidCredentials
  case networkError
}
