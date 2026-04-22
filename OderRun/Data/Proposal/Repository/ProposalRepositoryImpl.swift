//
//  ProposalRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

final class ProposalRepositoryImpl: ProposalRepositoryProtocol, Sendable {
  func fetchProposals(page _: Int, size _: Int) async throws -> [Proposal] {
    // TODO: Step 4 에서 seed 채움
    []
  }

  func fetchProposal(id _: Int64) async throws -> Proposal {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notFound
  }

  func createProposal(
    title _: String,
    content _: String,
    deadline _: String,
    errandFee _: String
  ) async throws -> Proposal {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }

  func updateProposal(
    id _: Int64,
    title _: String,
    content _: String,
    deadline _: String,
    errandFee _: String
  ) async throws -> Proposal {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }

  func cancelProposal(id _: Int64) async throws -> Proposal {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }
}
