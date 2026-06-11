//
//  NotificationRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  더미 전용 인메모리 구현. 실 API 는 `NotificationRepository` 사용.
//

import Foundation

actor NotificationRepositoryImpl: NotificationRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 500_000_000

  private var notifications: [AppNotification] = AppNotification.dummyList

  func fetchNotifications() async throws -> [AppNotification] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return notifications.sorted { $0.createdAt > $1.createdAt }
  }

  func markAsRead(ids: [Int]) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    for id in ids {
      guard let index = notifications.firstIndex(where: { $0.id == id }) else {
        continue
      }
      let existing = notifications[index]
      notifications[index] = AppNotification(
        id: existing.id,
        title: existing.title,
        body: existing.body,
        createdAt: existing.createdAt,
        isRead: true
      )
    }
  }
}
