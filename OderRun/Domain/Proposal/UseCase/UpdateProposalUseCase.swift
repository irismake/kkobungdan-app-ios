//
//  UpdateProposalUseCase.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct UpdateProposalUseCase {
  private let repository: ProposalRepositoryProtocol

  init(repository: ProposalRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    id: Int64,
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal {
    try await repository.updateProposal(
      id: id,
      title: title,
      content: content,
      deadline: deadline,
      errandFee: errandFee
    )
  }
}
