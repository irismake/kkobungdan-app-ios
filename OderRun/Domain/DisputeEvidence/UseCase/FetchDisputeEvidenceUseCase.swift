//
//  FetchDisputeEvidenceUseCase.swift
//  OderRun
//
//  Created by 김가희 on 7/2/26.
//

import Foundation

struct FetchDisputeEvidenceUseCase {
  private let repository: DisputeEvidenceRepositoryProtocol

  init(repository: DisputeEvidenceRepositoryProtocol) {
    self.repository = repository
  }

  func execute(for query: DisputeEvidenceQuery) async throws -> DisputeEvidence {
    try await repository.fetchEvidence(for: query)
  }
}
