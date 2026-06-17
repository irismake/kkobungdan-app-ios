//
//  UserDetailResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct UserDetailResponseDTO: Decodable {
  let id: String
  let name: String
  let level: Int
  let phone: String?
  let phoneVerifiedAt: String?
  let createdAt: String
  let lastLoginAt: String?
  let alarmEnabled: Bool
}

extension UserDetailResponseDTO {
  func toDomain() -> User {
    // TODO: level, phone, phoneVerifiedAt, createdAt, lastLoginAt — UI 반영 시 엔티티에 추가
    User(
      id: id,
      name: name,
      alarmEnabled: alarmEnabled
    )
  }
}
