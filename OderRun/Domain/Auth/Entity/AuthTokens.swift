//
//  AuthTokens.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct AuthTokens: Equatable {
  let accessToken: String
  let refreshToken: String
  let userID: String
  let tokenType: String

  /// userID·tokenType 을 응답에 담지 않는 경로(이메일·애플·카카오)는 기본값을 사용한다.
  /// SMS 인증(회원가입/로그인) 경로만 서버가 내려준 실제 값을 채운다.
  init(accessToken: String, refreshToken: String, userID: String = "", tokenType: String = "Bearer") {
    self.accessToken = accessToken
    self.refreshToken = refreshToken
    self.userID = userID
    self.tokenType = tokenType
  }
}
