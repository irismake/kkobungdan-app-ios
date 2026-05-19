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
