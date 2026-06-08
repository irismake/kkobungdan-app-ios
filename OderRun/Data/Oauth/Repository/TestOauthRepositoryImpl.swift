//
//  TestOauthRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

/// 소셜·이메일 로그인은 실 API 전용 — 호출부에서 OauthRepository() 를 직접 주입한다.
actor TestOauthRepositoryImpl: OauthRepositoryProtocol {
  func emailLogin(email _: String, password _: String) async throws -> AuthTokens {
    throw RepositoryError.notImplemented
  }

  func loginWithApple(identityToken _: String, name _: String?, email _: String?) async throws -> AppleLoginResult {
    throw RepositoryError.notImplemented
  }

  func loginWithKakao(accessToken _: String) async throws -> KakaoLoginResult {
    throw RepositoryError.notImplemented
  }
}
