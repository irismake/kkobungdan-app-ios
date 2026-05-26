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
  let identityToken: String
  let name: String?
  let email: String?
}

private struct KakaoLoginRequestBody: Encodable {
  let kakaoAccessToken: String
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
    let _: String = try await client.post(
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

  func loginWithApple(identityToken: String, name: String?, email: String?) async throws -> AppleLoginResult {
    let response: AppleLoginResponseDTO = try await client.post(
      "/v1/auth/oauth/apple",
      body: AppleLoginRequestBody(identityToken: identityToken, name: name, email: email)
    )
    tokenStorage.accessToken = response.accessToken
    tokenStorage.refreshToken = response.refreshToken
    tokenStorage.userID = response.userID
    return response.toDomain()
  }

  func loginWithKakao(accessToken: String) async throws -> KakaoLoginResult {
    let response: KakaoLoginResponseDTO = try await client.post(
      "/v1/auth/oauth/kakao",
      body: KakaoLoginRequestBody(kakaoAccessToken: accessToken)
    )
    tokenStorage.accessToken = response.accessToken
    tokenStorage.refreshToken = response.refreshToken
    tokenStorage.userID = response.userID
    return response.toDomain()
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

  func logout(refreshToken: String) async throws {
    try await client.postVoid(
      "/v1/auth/logout",
      body: LogoutRequestBody(refreshToken: refreshToken)
    )
    tokenStorage.clear()
  }
}
