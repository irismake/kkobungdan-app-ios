//
//  RefreshTokenResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//

import Foundation

struct RefreshTokenResponseDTO: Decodable {
  let accessToken: String
  let expiresIn: Int
}

extension RefreshTokenResponseDTO {
  // TODO: expiresIn UI/로직 반영 시 엔티티에 추가
  static let stubExpiresIn: Int = 0
}
