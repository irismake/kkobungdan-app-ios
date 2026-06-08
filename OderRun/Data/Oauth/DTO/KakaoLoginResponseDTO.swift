//
//  KakaoLoginResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/12/26.
//

import Foundation

struct KakaoLoginResponseDTO: Decodable {
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

extension KakaoLoginResponseDTO {
  func toDomain() -> KakaoLoginResult {
    KakaoLoginResult(
      tokens: AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
      userID: userID,
      profileSyncRequired: profileSyncRequired
    )
  }
}
