//
//  ProposalDetail.swift
//  OderRun
//
//  Created by 김가희 on 5/22/26.
//

import Foundation

struct ProposalDetail: Equatable, Identifiable {
  let id: Int64
  let title: String
  let content: String
  let deadline: Date
  let meetingAt: Date
  let errandFee: Int
  let itemPrice: Int
  let deposit: Int
  let status: ProposalStatus
}
