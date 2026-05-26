//
//  Proposal.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

struct Proposal: Equatable, Identifiable {
  let id: Int64
  let title: String
  let content: String
  let deadline: Date
  let errandFee: Int
  let status: ProposalStatus
}
