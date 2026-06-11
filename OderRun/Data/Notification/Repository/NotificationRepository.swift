//
//  NotificationRepository.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

private struct NotificationMarkReadRequest: Encodable {
  let notificationIDs: [Int]

  enum CodingKeys: String, CodingKey {
    case notificationIDs = "notification_ids"
  }
}

final class NotificationRepository: NotificationRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchNotifications() async throws -> [AppNotification] {
    let dto: NotificationListResponseDTO =
      try await client.get("/api/v1/notifications")
    return dto.notifications.map { $0.toDomain() }
  }

  func markAsRead(ids: [Int]) async throws {
    // mark-read 응답 본문은 사용하지 않으므로 상태코드만 확인한다.
    try await client.postVoid(
      "/api/v1/notifications/mark-read",
      body: NotificationMarkReadRequest(notificationIDs: ids)
    )
  }
}
