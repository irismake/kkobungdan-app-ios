//
//  AppleLoginResult.swift
//  OderRun
//
//  Created by 김가희 on 5/11/26.
//

import Foundation

struct AppleLoginResult: Equatable {
  let tokens: AuthTokens
  let isFirstLogin: Bool
}
