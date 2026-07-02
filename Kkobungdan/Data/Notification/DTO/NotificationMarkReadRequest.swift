//
//  NotificationMarkReadRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/notifications/mark-read` (알림 읽음 처리) 요청 바디. (서버: `NotificationMarkReadRequest`)
//

import Foundation

struct NotificationMarkReadRequest: Encodable {
  let notificationIDs: [Int]

  enum CodingKeys: String, CodingKey {
    case notificationIDs = "notification_ids"
  }
}
