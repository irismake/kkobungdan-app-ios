//
//  AuthLoginSendRequest.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/auth/login/send` (로그인 인증번호 발송) 요청 바디. (서버: `AuthLoginSendRequest`)
//

import Foundation

struct AuthLoginSendRequest: Encodable {
  let phone: String
}
