//
//  AuthRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog

private let authLogger = Logger(subsystem: "com.oderrun.OderRun", category: "Auth")

private struct SignupSendRequestBody: Encodable {
  let carrier: String
  let name: String
  let phone: String
}

private struct SignupConfirmRequestBody: Encodable {
  let code: String
  let phone: String
}

private struct LoginSendRequestBody: Encodable {
  let phone: String
}

private struct LoginConfirmRequestBody: Encodable {
  let code: String
  // TODO: fcmToken — 푸시 연동 전까지 stub 값 전송
  let fcmToken: String?
  let phone: String

  init(code: String, phone: String) {
    self.code = code
    self.phone = phone
    fcmToken = LoginConfirmRequestBody.stubFCMToken
  }
}

extension LoginConfirmRequestBody {
  // TODO: fcmToken 푸시 연동 시 호출부에서 실제 값 전달로 교체
  static let stubFCMToken: String? = nil
}

private struct SignupRequestBody: Encodable {
  let email: String
  let password: String
  let name: String
  let phone: String
}

private struct RefreshRequestBody: Encodable {
  let refreshToken: String
}

private struct LogoutRequestBody: Encodable {
  let refreshToken: String
}

final class AuthRepository: AuthRepositoryProtocol {
  private let client: HTTPClient
  private let tokenStorage: TokenStorage

  init(client: HTTPClient = .shared, tokenStorage: TokenStorage = .shared) {
    self.client = client
    self.tokenStorage = tokenStorage
  }

  func sendSignupCode(name: String, phone: String, carrier: String) async throws -> PhoneVerification {
    let response: PhoneVerificationResponseDTO = try await client.post(
      "/v1/auth/signup/send",
      body: SignupSendRequestBody(carrier: carrier, name: name, phone: phone)
    )
    return response.toDomain()
  }

  func confirmSignupCode(code: String, phone: String) async throws -> AuthTokens {
    let response: AuthTokenResponseDTO = try await client.post(
      "/v1/auth/signup/confirm",
      body: SignupConfirmRequestBody(code: code, phone: phone)
    )
    let tokens = response.toDomain()
    store(tokens)
    return tokens
  }

  func sendLoginCode(phone: String) async throws -> PhoneVerification {
    let response: PhoneVerificationResponseDTO = try await client.post(
      "/v1/auth/login/send",
      body: LoginSendRequestBody(phone: phone)
    )
    return response.toDomain()
  }

  func confirmLoginCode(code: String, phone: String) async throws -> AuthTokens {
    let response: AuthTokenResponseDTO = try await client.post(
      "/v1/auth/login/confirm",
      body: LoginConfirmRequestBody(code: code, phone: phone)
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
      body: RefreshRequestBody(refreshToken: refreshToken)
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
        body: LogoutRequestBody(refreshToken: refreshToken)
      )
    } catch {
      authLogger.warning("로그아웃 서버 통지 실패, 로컬 토큰만 정리: \(error.localizedDescription)")
    }
  }
}
