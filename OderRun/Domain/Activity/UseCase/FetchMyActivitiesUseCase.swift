//
//  FetchMyActivitiesUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/13/26.
//

import Foundation

struct FetchMyActivitiesUseCase {
  private let repository: ActivityRepositoryProtocol

  init(repository: ActivityRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    role: MissionRole? = nil,
    status: MissionStatus? = nil,
    page: Int = 0,
    size: Int = 20
  ) async throws -> [Mission] {
    try await repository.fetchMyActivities(role: role, status: status, page: page, size: size)
  }
}
