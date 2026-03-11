//
//  Proposal.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

struct Proposal: Equatable {
  let id: String
  let title: String
  let content: String
  let deadline: String
  let errandFee: String
  let status: ProposalStatus
}
