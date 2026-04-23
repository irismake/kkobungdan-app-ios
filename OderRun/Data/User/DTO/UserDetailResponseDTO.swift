//
//  UserDetailResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct UserDetailResponseDTO: Decodable {
  let id: String
  let email: String
  let name: String
  let phone: String
  let createdAt: String
  let lastLoginAt: String
  let alarmEnabled: Bool
}

extension UserDetailResponseDTO {
  func toDomain() -> User {
    User(
      id: id,
      email: email,
      name: name,
      phone: phone,
      createdAt: DateFormatters.parse(createdAt),
      lastLoginAt: DateFormatters.parse(lastLoginAt),
      alarmEnabled: alarmEnabled
    )
  }
}
