//
//  AuthTokenResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

struct AuthTokenResponseDTO: Decodable {
  let accessToken: String
  let refreshToken: String
  let tokenType: String
  let expiresIn: Int
  let userID: String

  private enum CodingKeys: String, CodingKey {
    case accessToken
    case refreshToken
    case tokenType
    case expiresIn
    case userID = "userId"
  }
}

extension AuthTokenResponseDTO {
  func toDomain() -> AuthTokens {
    // TODO: expiresIn — UI 반영 시 엔티티에 추가
    AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userID: userID,
      tokenType: tokenType
    )
  }
}
