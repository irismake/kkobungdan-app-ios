//
//  TestProposalRepositoryImpl.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

struct TestProposalRepositoryImpl: ProposalRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  let store: DummyBackendStore

  func fetchProposals(status: [ProposalStatus], page: Int, size: Int) async throws -> [Proposal] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchProposals(status: status, page: page, size: size)
  }

  func fetchProposal(id: Int64) async throws -> ProposalDetail {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.fetchProposal(id: id)
  }

  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: Int
  ) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.createProposal(
      ordererID: DummySession.currentUserID,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: errandFee
    )
  }

  func updateProposal(
    id: Int64,
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.updateProposal(
      id: id,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: Int(errandFee)
    )
  }

  func cancelProposal(id: Int64) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.cancelProposal(id: id)
  }

  func confirmReceived(proposalID: Int64) async throws -> ProposalDetail {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.confirmReceived(proposalID: proposalID)
  }

  func raiseDispute(proposalID: Int64, surveyQuestionID: Int64, reason: String) async throws -> ProposalDetail {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.raiseProposalDispute(proposalID: proposalID, surveyQuestionID: surveyQuestionID, reason: reason)
  }
}
