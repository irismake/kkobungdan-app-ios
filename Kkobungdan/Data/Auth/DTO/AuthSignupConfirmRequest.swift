//
//  AuthSignupConfirmRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/auth/signup/confirm` (회원가입 인증번호 확인) 요청 바디. fcmToken 은 서버 optional. (서버: `AuthSignupConfirmRequest`)
//

import Foundation

struct AuthSignupConfirmRequest: Encodable {
  let code: String
  let fcmToken: String?
  let phone: String
}
