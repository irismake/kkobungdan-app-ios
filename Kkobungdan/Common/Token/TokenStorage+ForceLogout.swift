//
//  TokenStorage+ForceLogout.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/26/26.
//

import Foundation

extension TokenStorage {
  /// 토큰을 클리어하고 UI 레이어가 로그인 화면으로 복귀하도록 알림을 발송한다.
  /// refresh 실패 등 비자발적 세션 종료 경로에서 호출한다.
  func forceLogout() {
    clear()
    Task { @MainActor in
      NotificationCenter.default.post(name: .authForcedLogout, object: nil)
    }
  }
}
