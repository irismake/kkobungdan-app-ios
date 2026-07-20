//
//  NotificationRepositoryImpl.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//
//  더미 전용 인메모리 구현. 실 API 는 `NotificationRepository` 사용.
//

import Foundation

actor NotificationRepositoryImpl: NotificationRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 500_000_000

  private var notifications: [AppNotification] = AppNotification.dummyList

  func fetchNotifications(page: Int, pageSize: Int, unreadOnly: Bool) async throws -> NotificationPage {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let filtered = notifications
      .sorted { $0.createdAt > $1.createdAt }
      .filter { !unreadOnly || !$0.isRead }
    let items = Array(filtered.dropFirst((page - 1) * pageSize).prefix(pageSize))
    return NotificationPage(notifications: items, hasNext: page * pageSize < filtered.count)
  }

  func markAsRead(ids: [Int]) async throws -> Int {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    var marked = 0
    for id in ids {
      guard let index = notifications.firstIndex(where: { $0.id == id }) else {
        continue
      }
      let existing = notifications[index]
      if !existing.isRead {
        marked += 1
      }
      notifications[index] = AppNotification(
        id: existing.id,
        title: existing.title,
        body: existing.body,
        createdAt: existing.createdAt,
        isRead: true,
        deepLink: existing.deepLink
      )
    }
    return marked
  }

  func fetchStats() async throws -> NotificationStats {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let unread = notifications.filter { !$0.isRead }.count
    return NotificationStats(
      total: notifications.count,
      unread: unread,
      failed: 0,
      read: notifications.count - unread
    )
  }
}
