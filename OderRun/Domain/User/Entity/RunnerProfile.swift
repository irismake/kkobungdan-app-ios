//
//  RunnerProfile.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  `GET /v1/user/{id}` 응답에 대응되는 도메인 모델.
//  지원자 카드 등 러너 표시에 사용되는 공개 프로필.
//

import Foundation

struct RunnerProfile: Equatable, Identifiable {
  let id: String
  let nickname: String
  let level: Int
  let grade: String
}
