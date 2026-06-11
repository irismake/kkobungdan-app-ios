//
//  ProposalRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

protocol ProposalRepositoryProtocol: Sendable {
  /// 홈 피드 proposal 목록. `status` 다중값 필터(`status=A&status=B`), 빈 배열이면 필터 미적용.
  func fetchProposals(status: [ProposalStatus], page: Int, size: Int) async throws -> [Proposal]
  func fetchProposal(id: Int64) async throws -> Proposal
  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: Int
  ) async throws -> Proposal
  func updateProposal(
    id: Int64,
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal
  func cancelProposal(id: Int64) async throws -> Proposal
  /// 오더러 수령 확인. `POST /v1/proposal/{id}/confirm-received`
  func confirmReceived(proposalID: Int64) async throws -> Proposal
  /// 오더러 분쟁 제기. `POST /v1/proposal/{id}/dispute`
  func raiseDispute(proposalID: Int64, reason: String) async throws -> Proposal
}
