//
//  RaiseProposalDisputeUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//
//  오더러 분쟁 제기. `POST /v1/proposal/{id}/dispute`
//

import Foundation

struct RaiseProposalDisputeUseCase {
  private let repository: ProposalRepositoryProtocol

  init(repository: ProposalRepositoryProtocol) {
    self.repository = repository
  }

  func execute(proposalID: Int64, reasonQuestionID: Int64, detailReason: String?) async throws -> ProposalDetail {
    try await repository.raiseDispute(proposalID: proposalID, reasonQuestionID: reasonQuestionID, detailReason: detailReason)
  }
}
