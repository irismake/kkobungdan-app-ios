//
//  FetchNotificationsUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct FetchNotificationsUseCase {
  private let repository: NotificationRepositoryProtocol

  init(repository: NotificationRepositoryProtocol) {
    self.repository = repository
  }

  func execute() async throws -> [AppNotification] {
    try await repository.fetchNotifications()
  }
}
