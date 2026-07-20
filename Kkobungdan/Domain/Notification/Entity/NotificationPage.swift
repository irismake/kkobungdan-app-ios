//
//  NotificationPage.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/20/26.
//

import Foundation

/// 알림 목록 한 페이지. `hasNext` 로 무한 스크롤 계속 여부를 판단한다.
struct NotificationPage {
  let notifications: [AppNotification]
  let hasNext: Bool
}
