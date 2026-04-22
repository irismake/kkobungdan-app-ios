//
//  ProposalRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

actor ProposalRepositoryImpl: ProposalRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  private var proposals: [Proposal] = Proposal.dummyList
  private var nextID: Int64 = 100

  func fetchProposals(page: Int, size: Int) async throws -> [Proposal] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let start = page * size
    guard start < proposals.count else {
      return []
    }
    return Array(proposals[start ..< min(start + size, proposals.count)])
  }

  func fetchProposal(id: Int64) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let proposal = proposals.first(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    return proposal
  }

  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let newID = nextID
    nextID += 1
    let proposal = Proposal(
      id: newID,
      ordererID: DummySession.currentUserID,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: Int(errandFee) ?? 0,
      status: .posted
    )
    proposals.insert(proposal, at: 0)
    return proposal
  }

  func updateProposal(
    id: Int64,
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = proposals.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = proposals[index]
    guard existing.status == .posted || existing.status == .offered else {
      throw RepositoryError.conflict
    }
    let updated = Proposal(
      id: existing.id,
      ordererID: existing.ordererID,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: Int(errandFee) ?? existing.errandFee,
      status: existing.status
    )
    proposals[index] = updated
    return updated
  }

  func cancelProposal(id: Int64) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = proposals.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = proposals[index]
    guard existing.status == .posted || existing.status == .offered else {
      throw RepositoryError.conflict
    }
    let updated = Proposal(
      id: existing.id,
      ordererID: existing.ordererID,
      title: existing.title,
      content: existing.content,
      deadline: existing.deadline,
      errandFee: existing.errandFee,
      status: .cancelled
    )
    proposals[index] = updated
    return updated
  }
}
