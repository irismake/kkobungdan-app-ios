//
//  Notification.Name+ProposalRefresh.swift
//  Kkobungdan
//

import Foundation

extension Notification.Name {
  /// Proposal/offer 상태 전이 후 홈·내 활동 목록을 서버 기준으로 다시 맞추기 위한 앱 내부 이벤트.
  static let proposalListNeedsRefresh = Notification.Name("proposalListNeedsRefresh")
}
