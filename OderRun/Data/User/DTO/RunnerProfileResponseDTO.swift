//
//  RunnerProfileResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  `GET /v1/user/{id}` 응답 DTO.
//

import Foundation

struct RunnerProfileResponseDTO: Decodable {
  let id: String
  let nickname: String
  let level: Int
  let grade: String
}

extension RunnerProfileResponseDTO {
  func toDomain() -> RunnerProfile {
    RunnerProfile(
      id: id,
      nickname: nickname,
      level: level,
      grade: grade
    )
  }
}
