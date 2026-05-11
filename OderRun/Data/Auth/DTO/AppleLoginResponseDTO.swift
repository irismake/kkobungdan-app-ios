//
//  AppleLoginResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/11/26.
//

import Foundation

struct AppleLoginResponseDTO: Decodable {
  let accessToken: String
  let refreshToken: String
  let isFirstLogin: Bool
}

extension AppleLoginResponseDTO {
  func toDomain() -> AppleLoginResult {
    AppleLoginResult(
      tokens: AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
      isFirstLogin: isFirstLogin
    )
  }
}
