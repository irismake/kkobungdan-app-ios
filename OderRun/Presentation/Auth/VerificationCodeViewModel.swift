//
//  VerificationCodeViewModel.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 인증번호 입력 상태. 6자리 입력 + 5분 제한 타이머를 관리한다.
@Observable
final class VerificationCodeViewModel {
  /// 인증 제한 시간(초).
  static let timeoutSeconds = 300

  var code: String = ""
  private(set) var remainingSeconds: Int = timeoutSeconds

  /// 남은 시간을 mm:ss 로 표기.
  var timerText: String {
    String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
  }

  /// 6자리를 모두 채우고 시간이 남아 있어야 확인 가능.
  var canProceed: Bool {
    code.count == 6 && remainingSeconds > 0
  }

  /// 숫자만 추려 최대 6자리까지.
  func inputCode(_ input: String) {
    code = String(input.filter(\.isNumber).prefix(6))
  }

  /// 1초마다 호출. 0에서 더 내려가지 않는다.
  func tick() {
    if remainingSeconds > 0 {
      remainingSeconds -= 1
    }
  }

  /// 인증번호 재전송 — 타이머를 초기화한다.
  func resend() {
    remainingSeconds = Self.timeoutSeconds
    code = ""
    // TODO: 인증번호 재전송 API 연동
  }
}
