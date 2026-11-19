//
//  ChatRoomStatus+Badge.swift
//  Kkobungdan
//

import Foundation

extension ChatRoomStatus {
  /// 요청·수행 기록 카드와 같은 배지(문구·색)를 쓴다.
  var badge: BadgeItem {
    switch self {
    case .waiting: return ActivityStatusBadge.waitingBadge
    case .inProgress: return ActivityStatusBadge.inProgressBadge
    case .completed: return ActivityStatusBadge.completedBadge
    case .cancelled: return ActivityStatusBadge.cancelledBadge
    case .disputed: return ActivityStatusBadge.disputedBadge
    }
  }
}
