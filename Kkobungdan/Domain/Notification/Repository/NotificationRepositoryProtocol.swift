//
//  NotificationRepositoryProtocol.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol NotificationRepositoryProtocol: Sendable {
  func fetchNotifications() async throws -> [AppNotification]
  /// 읽음 처리한 알림 수를 반환한다. `POST /v1/notifications/mark-read`
  func markAsRead(ids: [Int]) async throws -> Int
  /// 알림 통계(전체/안읽음/실패/읽음). `GET /v1/notifications/stats/me`
  func fetchStats() async throws -> NotificationStats
}
