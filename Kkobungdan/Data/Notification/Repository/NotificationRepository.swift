//
//  NotificationRepository.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

final class NotificationRepository: NotificationRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchNotifications(page: Int, pageSize: Int, unreadOnly: Bool) async throws -> NotificationPage {
    let dto: NotificationListResponseDTO = try await client.get(
      "/v1/notifications",
      params: ["page": page, "page_size": pageSize, "unread_only": unreadOnly]
    )
    return dto.toDomain()
  }

  func markAsRead(ids: [Int]) async throws -> Int {
    let dto: NotificationMarkReadResponseDTO = try await client.post(
      "/v1/notifications/mark-read",
      body: NotificationMarkReadRequest(notificationIDs: ids)
    )
    return dto.toDomain()
  }

  func fetchStats() async throws -> NotificationStats {
    let dto: NotificationStatsResponseDTO =
      try await client.get("/v1/notifications/stats/me")
    return dto.toDomain()
  }
}
