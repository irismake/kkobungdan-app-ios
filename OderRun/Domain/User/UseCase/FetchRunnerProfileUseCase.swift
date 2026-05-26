//
//  FetchRunnerProfileUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//

import Foundation

struct FetchRunnerProfileUseCase {
  private let repository: UserRepositoryProtocol

  init(repository: UserRepositoryProtocol) {
    self.repository = repository
  }

  func execute(runnerID: String) async throws -> RunnerProfile {
    try await repository.fetchRunner(id: runnerID)
  }
}
