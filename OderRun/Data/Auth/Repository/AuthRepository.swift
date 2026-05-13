//
//  AuthRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

private struct LoginRequestBody: Encodable {
  let email: String
  let password: String
}

private struct SignupRequestBody: Encodable {
  let email: String
  let password: String
  let name: String
  let phone: String
}

private struct AppleLoginRequestBody: Encodable {
  let authorizationCode: String
  let userName: String?
}

private struct KakaoLoginRequestBody: Encodable {
  let accessToken: String
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

  func signup(email: String, password: String, name: String, phone: String) async throws {
    let _: ApiResponseDTO<String> = try await client.post(
      "/v1/auth/signup",
      body: SignupRequestBody(email: email, password: password, name: name, phone: phone)
    )
  }

  func login(email: String, password: String) async throws -> AuthTokens {
    let response: LoginResponseDTO = try await client.post(
      "/v1/auth/login",
      body: LoginRequestBody(email: email, password: password)
    )
    tokenStorage.accessToken = response.accessToken
    tokenStorage.refreshToken = response.refreshToken
    return response.toDomain()
  }

  func loginWithApple(authorizationCode: String, userName: String?) async throws -> AppleLoginResult {
    // TODO: 서버 API 스펙 확정 시 path/필드명 조정 필요
    let response: AppleLoginResponseDTO = try await client.post(
      "/v1/auth/oauth/apple",
      body: AppleLoginRequestBody(authorizationCode: authorizationCode, userName: userName)
    )
    tokenStorage.accessToken = response.accessToken
    tokenStorage.refreshToken = response.refreshToken
    return response.toDomain()
  }

  func loginWithKakao(accessToken: String) async throws -> KakaoLoginResult {
    // TODO: 서버 API 스펙 확정 시 path/필드명 조정 필요
    let response: KakaoLoginResponseDTO = try await client.post(
      "/v1/auth/oauth/kakao",
      body: KakaoLoginRequestBody(accessToken: accessToken)
    )
    tokenStorage.accessToken = response.accessToken
    tokenStorage.refreshToken = response.refreshToken
    return response.toDomain()
  }

  func refresh(refreshToken: String) async throws -> AuthTokens {
    let response: LoginResponseDTO = try await client.post(
      "/v1/auth/refresh",
      body: RefreshRequestBody(refreshToken: refreshToken)
    )
    tokenStorage.accessToken = response.accessToken
    tokenStorage.refreshToken = response.refreshToken
    return response.toDomain()
  }

  func logout(refreshToken: String) async throws {
    let _: ApiResponseDTO<String> = try await client.post(
      "/v1/auth/logout",
      body: LogoutRequestBody(refreshToken: refreshToken)
    )
    tokenStorage.clear()
  }
}
