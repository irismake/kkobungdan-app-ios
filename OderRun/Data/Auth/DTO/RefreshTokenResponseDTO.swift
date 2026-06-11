//
//  RefreshTokenResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//

import Foundation

struct RefreshTokenResponseDTO: Decodable {
  let accessToken: String
  // expiresIn: 서버 응답 스펙 일치를 위해 둠. 현재 미사용(토큰 갱신은 accessToken 만 사용).
  let expiresIn: Int
}
