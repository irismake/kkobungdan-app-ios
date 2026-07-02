//
//  ProposalDetail.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/17/26.
//
//  `GET /v1/proposal/{id}` 상세 응답 전용 엔티티.
//  목록 응답엔 없는 요청자(orderer) 레벨을 화면에서 사용하므로 `Proposal` 과 분리한다.
//

import Foundation

struct ProposalDetail: Equatable, Identifiable {
  let id: Int64
  let title: String
  let content: String
  let deadline: Date
  let errandFee: Int
  let status: ProposalStatus
  let ordererID: String
  let ordererName: String
  let ordererLevel: Int
  let openChatURL: String?
}
