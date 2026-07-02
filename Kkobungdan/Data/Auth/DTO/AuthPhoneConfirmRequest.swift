//
//  AuthPhoneConfirmRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/auth/signup/confirm` (회원가입 인증번호 확인) 요청 바디. (서버: `AuthPhoneConfirmRequest`)
//

import Foundation

struct AuthPhoneConfirmRequest: Encodable {
  let code: String
  let phone: String
}
