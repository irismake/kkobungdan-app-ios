//
//  AuthSignupSendRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/auth/signup/send` (회원가입 인증번호 발송) 요청 바디. (서버: `AuthSignupSendRequest`)
//

import Foundation

struct AuthSignupSendRequest: Encodable {
  let carrier: String
  let name: String
  let phone: String
}
