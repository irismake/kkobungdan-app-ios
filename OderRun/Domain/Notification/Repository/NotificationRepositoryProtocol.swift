//
//  NotificationRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol NotificationRepositoryProtocol: Sendable {
  func fetchNotifications() async throws -> [AppNotification]
  func markAsRead(ids: [Int]) async throws
}
