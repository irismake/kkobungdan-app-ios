//
//  AuthRepository.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog

private let authLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Auth")

// 인증번호 발송/확인·refresh·logout 요청 바디는 서버 스키마 추적을 위해 `Data/Auth/DTO/` 에
// internal DTO 로 분리되어 있다.

/// ⚠️ /v1/auth/signup(email/password) 은 현재 서버 OpenAPI 스펙에 없어 대조할 스키마가 없으므로
///    DTO 로 승격하지 않고 private 으로 둔다. (서버 스펙에 추가되면 그때 분리·등록)
private struct SignupRequestBody: Encodable {
  let email: String
  let password: String
  let name: String
  let phone: String
}

final class AuthRepository: AuthRepositoryProtocol {
  private let client: HTTPClient
  private let tokenStorage: TokenStorage
  private let fcmTokenStorage: FcmTokenStorage

  init(
    client: HTTPClient = .shared,
    tokenStorage: TokenStorage = .shared,
    fcmTokenStorage: FcmTokenStorage = .shared
  ) {
    self.client = client
    self.tokenStorage = tokenStorage
    self.fcmTokenStorage = fcmTokenStorage
  }

  func sendSignupCode(name: String, phone: String, carrier: String) async throws -> PhoneVerification {
    let response: PhoneVerificationResponseDTO = try await client.post(
      "/v1/auth/signup/send",
      body: AuthSignupSendRequest(carrier: carrier, name: name, phone: phone)
    )
    return response.toDomain()
  }

  func confirmSignupCode(code: String, phone: String) async throws -> AuthTokens {
    let response: AuthTokenResponseDTO = try await client.post(
      "/v1/auth/signup/confirm",
      body: AuthSignupConfirmRequest(code: code, fcmToken: fcmTokenStorage.token, phone: phone)
    )
    let tokens = response.toDomain()
    store(tokens)
    return tokens
  }

  func sendLoginCode(phone: String) async throws -> PhoneVerification {
    let response: PhoneVerificationResponseDTO = try await client.post(
      "/v1/auth/login/send",
      body: AuthLoginSendRequest(phone: phone)
    )
    return response.toDomain()
  }

  func confirmLoginCode(code: String, phone: String) async throws -> AuthTokens {
    let response: AuthTokenResponseDTO = try await client.post(
      "/v1/auth/login/confirm",
      body: AuthLoginConfirmRequest(code: code, fcmToken: fcmTokenStorage.token, phone: phone)
    )
    let tokens = response.toDomain()
    store(tokens)
    return tokens
  }

  /// 인증 성공으로 받은 토큰을 스토리지에 저장한다. 세션 판단(로그인/홈 분기)의 기준이 된다.
  private func store(_ tokens: AuthTokens) {
    tokenStorage.accessToken = tokens.accessToken
    tokenStorage.refreshToken = tokens.refreshToken
    tokenStorage.userID = tokens.userID
    tokenStorage.tokenType = tokens.tokenType
  }

  func signup(email: String, password: String, name: String, phone: String) async throws {
    let _: String = try await client.post(
      "/v1/auth/signup",
      body: SignupRequestBody(email: email, password: password, name: name, phone: phone)
    )
  }

  func refresh(refreshToken: String) async throws -> String {
    let response: RefreshTokenResponseDTO = try await client.post(
      "/v1/auth/refresh",
      body: AuthRefreshRequest(refreshToken: refreshToken)
    )
    // refreshToken은 서버 응답에 없으므로 기존 storage 값 유지
    tokenStorage.accessToken = response.accessToken
    return response.accessToken
  }

  /// 로그아웃은 항상 로컬 토큰을 정리한다. 서버 통지는 best-effort 로, 실패해도
  /// 로컬 세션은 강제 종료한다(예: refreshToken 만료로 서버가 거부하는 경우).
  func logout(refreshToken: String) async throws {
    defer { tokenStorage.clear() }
    do {
      try await client.postVoid(
        "/v1/auth/logout",
        body: AuthLogoutRequest(refreshToken: refreshToken)
      )
    } catch {
      authLogger.warning("로그아웃 서버 통지 실패, 로컬 토큰만 정리: \(error.localizedDescription)")
    }
  }
}
