//
//  RunnerProfileDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: 공식 스펙 외 — 서버에서 러너/오더 프로필을 제공하는 스펙이 확정되면 교체.
//

import Foundation

struct RunnerProfileDTO: Decodable {
  let id: String
  let nickname: String
  let level: Int
  let grade: String
}

extension RunnerProfileDTO {
  func toDomain() -> RunnerProfile {
    RunnerProfile(id: id, nickname: nickname, level: level, grade: grade)
  }
}
