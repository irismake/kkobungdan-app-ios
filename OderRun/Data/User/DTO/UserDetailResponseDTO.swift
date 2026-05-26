//
//  UserDetailResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct UserDetailResponseDTO: Decodable {
  let id: String
  let email: String?
  let name: String
  let phone: String?
  let phoneVerifiedAt: String?
  let createdAt: String
  let lastLoginAt: String
  let alarmEnabled: Bool
}

extension UserDetailResponseDTO {
  // TODO: phoneVerifiedAt UI 반영 시 User 엔티티에 추가
  static let stubPhoneVerifiedAt: String? = nil

  func toDomain() -> User {
    // TODO: phoneVerifiedAt — UI 반영 시 엔티티에 추가
    User(
      id: id,
      email: email ?? "",
      name: name,
      phone: phone ?? "",
      createdAt: DateFormatters.parse(createdAt),
      lastLoginAt: DateFormatters.parse(lastLoginAt),
      alarmEnabled: alarmEnabled
    )
  }
}
