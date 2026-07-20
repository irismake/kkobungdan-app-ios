//
//  Notification.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct AppNotification: Equatable, Identifiable {
  let id: Int
  let title: String
  let body: String
  let createdAt: Date
  let isRead: Bool
  let deepLink: PushPayload?
}
