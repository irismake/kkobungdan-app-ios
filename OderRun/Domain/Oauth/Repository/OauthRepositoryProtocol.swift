//
//  OauthRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

/// 소셜·이메일 로그인(oauth) 전용 리포지토리. SMS 인증/토큰 수명 관리는 AuthRepositoryProtocol 이 담당한다.
protocol OauthRepositoryProtocol: Sendable {
  func emailLogin(email: String, password: String) async throws -> AuthTokens
  func loginWithApple(identityToken: String, name: String?, email: String?) async throws -> AppleLoginResult
  func loginWithKakao(accessToken: String) async throws -> KakaoLoginResult
}
