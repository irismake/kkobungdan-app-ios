//
//  Proposal.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//
//  NOTE: ordererID 는 현재 스펙의 ProposalResponse 에 포함되지 않지만, "내 요청 vs 남의 요청"
//  분기를 위해 Domain 에서 보관한다. 서버 스펙 확정 시 응답에 포함되도록 조율 필요.
//

import Foundation

struct Proposal: Equatable, Identifiable {
  let id: Int64
  let ordererID: String
  let title: String
  let content: String
  let deadline: Date
  let errandFee: Int
  let status: ProposalStatus
}
