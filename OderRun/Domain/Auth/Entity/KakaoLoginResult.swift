//
//  KakaoLoginResult.swift
//  OderRun
//
//  Created by 김가희 on 5/12/26.
//

import Foundation

struct KakaoLoginResult: Equatable {
  let tokens: AuthTokens
  let userID: String
  let profileSyncRequired: Bool
}
