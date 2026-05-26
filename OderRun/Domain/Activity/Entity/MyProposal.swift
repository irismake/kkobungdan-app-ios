//
//  MyProposal.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//

import Foundation

struct MyProposal: Equatable, Identifiable {
  let id: Int64
  let title: String
  let content: String
  let deadline: Date
  let errandFee: Int
  let status: ProposalStatus
}
