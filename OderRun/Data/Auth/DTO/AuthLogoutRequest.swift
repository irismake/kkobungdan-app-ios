//
//  AuthLogoutRequest.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/auth/logout` (로그아웃) 요청 바디. (서버: `AuthLogoutRequest`)
//

import Foundation

struct AuthLogoutRequest: Encodable {
  let refreshToken: String
}
