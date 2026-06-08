//
//  PhoneVerificationResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

struct PhoneVerificationResponseDTO: Decodable {
  let phone: String
  let expiresAt: String
}

extension PhoneVerificationResponseDTO {
  // TODO: phone UI/로직 반영 시 PhoneVerification 엔티티에 추가
  static let stubPhone: String = ""

  func toDomain() -> PhoneVerification {
    // TODO: phone — UI 반영 시 엔티티에 추가
    PhoneVerification(expiresAt: DateFormatters.parse(expiresAt))
  }
}
