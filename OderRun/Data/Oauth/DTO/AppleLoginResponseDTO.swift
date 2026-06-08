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
  let userID: String
  let profileSyncRequired: Bool

  private enum CodingKeys: String, CodingKey {
    case accessToken
    case refreshToken
    case userID = "userId"
    case profileSyncRequired
  }
}

extension AppleLoginResponseDTO {
  func toDomain() -> AppleLoginResult {
    AppleLoginResult(
      tokens: AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
      userID: userID,
      profileSyncRequired: profileSyncRequired
    )
  }
}
