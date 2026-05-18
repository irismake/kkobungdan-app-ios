//
//  MyProposal.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  /v1/proposal/own 응답 항목. 현재 로그인한 오더(orderer)가 작성한 proposal 한 건과
//  연결된 offer 목록을 함께 묶어 노출한다.
//

import Foundation

struct MyProposal: Equatable, Identifiable {
  let id: Int64
  let title: String
  let content: String
  let deadline: Date
  let meetingAt: Date?
  let errandFee: Int
  let itemPrice: Int?
  let deposit: Int?
  let status: ProposalStatus
  /// 스펙상 각 Proposal 에 연결된 offer 목록이 같이 내려온다.
  let offers: [Offer]
}
