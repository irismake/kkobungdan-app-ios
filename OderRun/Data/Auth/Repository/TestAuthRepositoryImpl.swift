//
//  TestAuthRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

actor TestAuthRepositoryImpl: AuthRepositoryProtocol {
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

  func emailLogin(email _: String, password _: String) async throws -> AuthTokens {
    throw RepositoryError.notImplemented
  }

  /// 애플 로그인은 실 API 전용 — ContentView 에서 AuthRepository() 를 직접 주입한다.
  func loginWithApple(identityToken _: String, name _: String?, email _: String?) async throws -> AppleLoginResult {
    throw RepositoryError.notImplemented
  }

  /// 카카오 로그인은 실 API 전용 — ContentView 에서 AuthRepository() 를 직접 주입한다.
  func loginWithKakao(accessToken _: String) async throws -> KakaoLoginResult {
    throw RepositoryError.notImplemented
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
