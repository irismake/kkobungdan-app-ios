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

  func execute(
    page: Int = 1,
    pageSize: Int = 20,
    unreadOnly: Bool = false
  ) async throws -> NotificationPage {
    try await repository.fetchNotifications(page: page, pageSize: pageSize, unreadOnly: unreadOnly)
  }
}
