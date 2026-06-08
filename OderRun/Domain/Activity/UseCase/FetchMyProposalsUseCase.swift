//
//  FetchMyProposalsUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//

import Foundation

struct FetchMyProposalsUseCase {
  private let repository: ActivityRepositoryProtocol

  init(repository: ActivityRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    status: [ProposalStatus] = [],
    page: Int = 0,
    size: Int = 20
  ) async throws -> [MyProposal] {
    try await repository.fetchMyProposals(status: status, page: page, size: size)
  }
}
