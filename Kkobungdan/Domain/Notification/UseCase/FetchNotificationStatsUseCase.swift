//
//  FetchNotificationStatsUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

struct FetchNotificationStatsUseCase {
  private let repository: NotificationRepositoryProtocol

  init(repository: NotificationRepositoryProtocol) {
    self.repository = repository
  }

  func execute() async throws -> NotificationStats {
    try await repository.fetchStats()
  }
}
