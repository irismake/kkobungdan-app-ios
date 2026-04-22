//
//  NotificationRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: API 미정 — 더미 전용. Step 4 에서 seed 채움.
//

import Foundation

final class NotificationRepositoryImpl: NotificationRepositoryProtocol, Sendable {
  func fetchNotifications() async throws -> [AppNotification] {
    []
  }

  func markAsRead(id _: String) async throws {
    // no-op
  }
}
