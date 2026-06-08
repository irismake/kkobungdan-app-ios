//
//  TestAuthRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

actor TestAuthRepositoryImpl: AuthRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 800_000_000

  /// SMS 회원가입/로그인은 실 API 전용 — ContentView 에서 AuthRepository() 를 직접 주입한다.
  func sendSignupCode(name _: String, phone _: String, carrier _: String) async throws -> PhoneVerification {
    throw RepositoryError.notImplemented
  }

  func confirmSignupCode(code _: String, phone _: String) async throws -> AuthTokens {
    throw RepositoryError.notImplemented
  }

  func sendLoginCode(phone _: String) async throws -> PhoneVerification {
    throw RepositoryError.notImplemented
  }

  func confirmLoginCode(code _: String, phone _: String) async throws -> AuthTokens {
    throw RepositoryError.notImplemented
  }

  func signup(email: String, password: String, name: String, phone: String) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard !email.isEmpty, !password.isEmpty, !name.isEmpty, !phone.isEmpty else {
      throw RepositoryError.unauthorized
    }
    if email == "conflict@test.com" {
      throw RepositoryError.conflict
    }
  }

  func refresh(refreshToken: String) async throws -> String {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard refreshToken == DummySession.refreshToken else {
      throw RepositoryError.unauthorized
    }
    return DummySession.accessToken
  }

  /// 로그아웃도 실 API 전용 — ContentView 에서 AuthRepository() 를 직접 주입한다.
  func logout(refreshToken _: String) async throws {
    throw RepositoryError.notImplemented
  }
}
