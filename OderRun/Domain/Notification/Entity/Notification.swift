//
//  Notification.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: API 미정 — 더미 전용. 서버 스펙 확정 시 필드 재검토.
//

import Foundation

struct AppNotification: Equatable, Identifiable {
  let id: String
  let title: String
  let body: String
  let createdAt: Date
  let isRead: Bool
}
