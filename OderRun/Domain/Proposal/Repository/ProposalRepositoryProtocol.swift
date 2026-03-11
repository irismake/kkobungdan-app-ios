//
//  ProposalRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

protocol ProposalRepositoryProtocol: Sendable {
  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal
}
