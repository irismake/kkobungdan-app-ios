//
//  RunnerProfile.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: 서버 스펙 확정 시 Proposal/Offer 응답에 편입될 수 있음. 현재는 UI 보조용 더미.
//

import Foundation

struct RunnerProfile: Equatable, Identifiable {
  let id: String
  let nickname: String
  let level: Int
  let grade: String
}
