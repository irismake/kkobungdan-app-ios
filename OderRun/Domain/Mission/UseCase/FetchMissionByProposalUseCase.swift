//
//  FetchMissionByProposalUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/19/26.
//

import Foundation

struct FetchMissionByProposalUseCase {
  private let repository: MissionRepositoryProtocol

  init(repository: MissionRepositoryProtocol) {
    self.repository = repository
  }

  func execute(proposalID: Int64) async throws -> Mission? {
    try await repository.fetchMissionByProposal(proposalID: proposalID)
  }
}
