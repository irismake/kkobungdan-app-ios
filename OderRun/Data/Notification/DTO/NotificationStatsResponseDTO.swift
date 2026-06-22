//
//  NotificationStatsResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `GET /v1/notifications/stats/me` 응답의 `data` 페이로드. (서버: `NotificationStatsResponse`)
//  전역 디코더가 .convertFromSnakeCase 라 total_notifications → totalNotifications 등으로 매핑된다.
//

import Foundation

struct NotificationStatsResponseDTO: Decodable {
  let totalNotifications: Int
  let unreadCount: Int
  let failedCount: Int
  let readCount: Int
}

extension NotificationStatsResponseDTO {
  func toDomain() -> NotificationStats {
    NotificationStats(
      total: totalNotifications,
      unread: unreadCount,
      failed: failedCount,
      read: readCount
    )
  }
}
