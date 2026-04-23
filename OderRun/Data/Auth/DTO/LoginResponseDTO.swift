//
//  LoginResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct LoginResponseDTO: Decodable {
  let accessToken: String
  let refreshToken: String
}

extension LoginResponseDTO {
  func toDomain() -> AuthTokens {
    AuthTokens(accessToken: accessToken, refreshToken: refreshToken)
  }
}
