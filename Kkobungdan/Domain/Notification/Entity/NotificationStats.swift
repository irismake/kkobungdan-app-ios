//
//  NotificationStats.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `GET /v1/notifications/stats/me` 응답에 대응되는 알림 통계.
//

import Foundation

struct NotificationStats: Equatable {
  let total: Int
  let unread: Int
  let failed: Int
  let read: Int
}
