//
//  AuthNotifications.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//

import Foundation

extension Notification.Name {
  /// refresh 실패 등으로 세션이 강제 종료될 때 발송된다. UI 레이어가 로그인 화면으로 복귀시킨다.
  static let authForcedLogout = Notification.Name("orderrun.authForcedLogout")
}
