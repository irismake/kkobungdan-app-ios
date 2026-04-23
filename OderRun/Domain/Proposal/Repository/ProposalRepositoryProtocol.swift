//
//  ProposalRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

protocol ProposalRepositoryProtocol: Sendable {
  func fetchProposals(page: Int, size: Int) async throws -> [Proposal]
  func fetchProposal(id: Int64) async throws -> Proposal
  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal
  func updateProposal(
    id: Int64,
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal
  func cancelProposal(id: Int64) async throws -> Proposal
}
