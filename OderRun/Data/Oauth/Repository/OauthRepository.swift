//
//  OauthRepository.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

private struct EmailLoginRequestBody: Encodable {
  let email: String
  let password: String
}

private struct AppleLoginRequestBody: Encodable {
  let identityToken: String
  let name: String?
  let email: String?
}

private struct KakaoLoginRequestBody: Encodable {
  let kakaoAccessToken: String
}

final class OauthRepository: OauthRepositoryProtocol {
  private let client: HTTPClient
  private let tokenStorage: TokenStorage

  init(client: HTTPClient = .shared, tokenStorage: TokenStorage = .shared) {
    self.client = client
    self.tokenStorage = tokenStorage
  }

  func emailLogin(email: String, password: String) async throws -> AuthTokens {
    let response: LoginResponseDTO = try await client.post(
      "/v1/auth/login",
      body: EmailLoginRequestBody(email: email, password: password)
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
}
