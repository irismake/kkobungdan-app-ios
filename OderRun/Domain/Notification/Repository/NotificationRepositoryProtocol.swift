//
//  NotificationRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: API 미정 — 더미 전용.
//

import Foundation

protocol NotificationRepositoryProtocol: Sendable {
  func fetchNotifications() async throws -> [AppNotification]
  func markAsRead(id: String) async throws
}
