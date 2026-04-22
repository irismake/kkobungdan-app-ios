//
//  FetchProposalDetailUseCase.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct FetchProposalDetailUseCase {
  private let repository: ProposalRepositoryProtocol

  init(repository: ProposalRepositoryProtocol) {
    self.repository = repository
  }

  func execute(id: Int64) async throws -> Proposal {
    try await repository.fetchProposal(id: id)
  }
}
