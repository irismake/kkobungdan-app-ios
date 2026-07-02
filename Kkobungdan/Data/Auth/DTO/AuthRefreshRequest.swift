//
//  AuthRefreshRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/auth/refresh` (액세스 토큰 갱신) 요청 바디. (서버: `AuthRefreshRequest`)
//

import Foundation

struct AuthRefreshRequest: Encodable {
  let refreshToken: String
}
