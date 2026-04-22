//
//  NotificationDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: API 미정 — 더미 전용. 서버 스펙 확정 시 교체.
//

import Foundation

struct NotificationDTO: Decodable {
  let id: String
  let title: String
  let body: String
  let createdAt: String
  let isRead: Bool
}

extension NotificationDTO {
  func toDomain() -> AppNotification {
    AppNotification(
      id: id,
      title: title,
      body: body,
      createdAt: DateFormatters.parse(createdAt),
      isRead: isRead
    )
  }
}
