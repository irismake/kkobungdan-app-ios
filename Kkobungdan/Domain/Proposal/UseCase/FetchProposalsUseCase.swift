//
//  FetchProposalsUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct FetchProposalsUseCase {
  private let repository: ProposalRepositoryProtocol

  init(repository: ProposalRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    status: [ProposalStatus] = [],
    page: Int = 0,
    size: Int = 20
  ) async throws -> [Proposal] {
    try await repository.fetchProposals(status: status, page: page, size: size)
  }
}
