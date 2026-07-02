//
//  ConfirmReceivedUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//
//  오더러 수령 확인. `POST /v1/proposal/{id}/confirm-received`
//

import Foundation

struct ConfirmReceivedUseCase {
  private let repository: ProposalRepositoryProtocol

  init(repository: ProposalRepositoryProtocol) {
    self.repository = repository
  }

  func execute(proposalID: Int64) async throws -> ProposalDetail {
    try await repository.confirmReceived(proposalID: proposalID)
  }
}
