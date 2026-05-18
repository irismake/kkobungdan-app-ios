//
//  FetchMyMissionsUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//

import Foundation

struct FetchMyMissionsUseCase {
  private let repository: MissionRepositoryProtocol

  init(repository: MissionRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    role: MissionRole,
    status: MissionStatus? = nil,
    page: Int = 0,
    size: Int = 20
  ) async throws -> [Mission] {
    try await repository.fetchMyMissions(role: role, status: status, page: page, size: size)
  }
}
