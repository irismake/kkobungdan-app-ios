//
//  CreateProposalUseCase.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

struct CreateProposalUseCase {
  private let repository: ProposalRepositoryProtocol

  init(repository: ProposalRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    title: String,
    content: String,
    deadline: String,
    errandFee: Int
  ) async throws -> Proposal {
    try await repository.createProposal(
      title: title,
      content: content,
      deadline: deadline,
      errandFee: errandFee
    )
  }
}
