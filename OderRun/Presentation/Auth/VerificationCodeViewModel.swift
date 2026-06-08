//
//  VerificationCodeViewModel.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 인증번호 입력 상태. 6자리 입력 + 만료 타이머를 관리하고, 회원가입/로그인 인증번호 발송·확인을 수행한다.
@Observable
final class VerificationCodeViewModel {
  /// 인증 플로우. 진입 경로(회원가입/로그인)에 따라 발송·확인 API가 분기된다.
  enum Flow: Hashable {
    case signup(name: String, phone: String, carrier: String)
    case login(phone: String)
  }

  /// 인증 제한 시간(초). 서버 expiresAt 을 받기 전 기본값.
  static let timeoutSeconds = 300

  let flow: Flow
  private let sendSignupCodeUseCase: SendSignupCodeUseCase
  private let confirmSignupCodeUseCase: ConfirmSignupCodeUseCase
  private let sendLoginCodeUseCase: SendLoginCodeUseCase
  private let confirmLoginCodeUseCase: ConfirmLoginCodeUseCase

  var code: String = ""
  private(set) var remainingSeconds: Int = timeoutSeconds
  private(set) var isLoading: Bool = false
  var errorMessage: String?

  init(
    flow: Flow,
    sendSignupCodeUseCase: SendSignupCodeUseCase,
    confirmSignupCodeUseCase: ConfirmSignupCodeUseCase,
    sendLoginCodeUseCase: SendLoginCodeUseCase,
    confirmLoginCodeUseCase: ConfirmLoginCodeUseCase
  ) {
    self.flow = flow
    self.sendSignupCodeUseCase = sendSignupCodeUseCase
    self.confirmSignupCodeUseCase = confirmSignupCodeUseCase
    self.sendLoginCodeUseCase = sendLoginCodeUseCase
    self.confirmLoginCodeUseCase = confirmLoginCodeUseCase
  }

  /// 남은 시간을 mm:ss 로 표기.
  var timerText: String {
    String(format: "%02d:%02d", remainingSeconds / 60, remainingSeconds % 60)
  }

  /// 6자리를 모두 채우고 시간이 남아 있으며 통신 중이 아닐 때 확인 가능.
  var canProceed: Bool {
    code.count == 6 && remainingSeconds > 0 && !isLoading
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

  /// 화면 진입 시 인증번호를 발송하고 만료 타이머를 시작한다.
  @MainActor
  func sendCode() async {
    errorMessage = nil
    do {
      let verification: PhoneVerification
      switch flow {
      case let .signup(name, phone, carrier):
        verification = try await sendSignupCodeUseCase.execute(name: name, phone: phone, carrier: carrier)
      case let .login(phone):
        verification = try await sendLoginCodeUseCase.execute(phone: phone)
      }
      startTimer(until: verification.expiresAt)
    } catch {
      errorMessage = "인증번호 발송에 실패했습니다. 다시 시도해주세요."
    }
  }

  /// 인증번호 재전송 — 타이머·입력을 초기화하고 다시 발송한다.
  @MainActor
  func resend() async {
    code = ""
    remainingSeconds = Self.timeoutSeconds
    await sendCode()
  }

  /// 인증번호를 확인한다. 성공하면 true 를 반환한다.
  @MainActor
  func confirm() async -> Bool {
    guard canProceed else {
      return false
    }
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      switch flow {
      case let .signup(_, phone, _):
        _ = try await confirmSignupCodeUseCase.execute(code: code, phone: phone)
      case let .login(phone):
        _ = try await confirmLoginCodeUseCase.execute(code: code, phone: phone)
      }
      return true
    } catch {
      errorMessage = "인증번호가 올바르지 않습니다. 다시 확인해주세요."
      return false
    }
  }

  /// 서버 만료 시각으로 남은 시간을 설정한다. (0 ~ 기본 제한 사이로 보정)
  private func startTimer(until expiresAt: Date) {
    let remaining = Int(expiresAt.timeIntervalSinceNow.rounded())
    remainingSeconds = max(0, min(Self.timeoutSeconds, remaining))
  }
}
