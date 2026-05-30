//
//  SignupViewModel.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 본인인증 플로우 상태. 하나의 화면에서 step이 진행될수록 입력 필드가 누적된다.
@Observable
final class SignupViewModel {
  enum Step: Int, CaseIterable, Comparable {
    static func < (lhs: Step, rhs: Step) -> Bool {
      lhs.rawValue < rhs.rawValue
    }

    case phoneNumber
    case carrier
    case name
    case birthDate
  }

  enum Focus {
    case phone
    case carrier
    case name
    case birth
  }

  var step: Step = .phoneNumber
  var focus: Focus? = .phone
  var phoneNumber: String = ""
  var carrier: String?
  var name: String = ""
  var birthDate: String = ""

  /// 통신사 시트 노출 여부. 포커스가 통신사일 때만 열린다.
  var isCarrierSheetPresented: Bool {
    focus == .carrier
  }

  let carriers = ["SKT", "KT", "LG U+", "SKT 알뜰폰", "KT 알뜰폰", "LG U+ 알뜰폰"]

  /// 모든 입력을 마친 뒤 띄우는 약관 동의 시트.
  let termsViewModel = TermsAgreementViewModel()
  var isTermsSheetPresented = false

  /// 현재 step의 헤더 문구.
  var title: String {
    switch step {
    case .phoneNumber: "휴대폰 정보를 입력해 주세요"
    case .carrier: "통신사를 선택해 주세요"
    case .name: "이름을 입력해주세요"
    case .birthDate: "생년월일을 입력해주세요"
    }
  }

  private var isPhoneValid: Bool {
    phoneNumber.filter(\.isNumber).count == 11
  }

  private var isCarrierValid: Bool {
    carrier != nil
  }

  private var isNameValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty
  }

  private var isBirthDateValid: Bool {
    birthDate.count == 7
  }

  /// 현재 step을 완료할 수 있는지. 진행된 단계에서 이전 필드를 비우면 다시 비활성화되도록 누적 검사한다.
  var canProceed: Bool {
    switch step {
    case .phoneNumber: isPhoneValid
    case .carrier: isPhoneValid && isCarrierValid
    case .name: isPhoneValid && isCarrierValid && isNameValid
    case .birthDate: isPhoneValid && isCarrierValid && isNameValid && isBirthDateValid
    }
  }

  /// 하단 버튼(이름·생년월일 step)에서 다음 단계를 노출한다.
  func goNext() {
    switch step {
    case .name:
      reveal(.birthDate)
      focus = .birth
    case .birthDate:
      focus = nil // 키보드를 내리고 약관 동의 시트를 띄운다.
      isTermsSheetPresented = true
    default:
      break
    }
  }

  /// 약관 시트를 동의 없이 닫는다.
  func dismissTermsSheet() {
    isTermsSheetPresented = false
  }

  /// 약관 동의 완료. 시트를 닫는다. (이후 인증 단계 이동은 View 의 onComplete 가 처리)
  func completeTermsAgreement() {
    isTermsSheetPresented = false
  }

  func fommatPhoneNumber(_ input: String) {
    let formatted = Self.formatPhoneNumber(input)
    if formatted != phoneNumber {
      phoneNumber = formatted
    }
    if formatted.filter(\.isNumber).count == 11, step == .phoneNumber {
      reveal(.carrier)
      focus = .carrier
    }
  }

  func openCarrierSheet() {
    focus = .carrier
  }

  func dismissCarrierSheet() {
    if focus == .carrier {
      focus = nil
    }
  }

  func selectCarrier(_ value: String) {
    carrier = value
    if step == .carrier {
      reveal(.name)
      focus = .name
    } else {
      focus = nil
    }
  }

  /// 더 진행된 단계까지 필드 가시성을 확장한다. (이미 지난 단계로는 되돌아가지 않음)
  private func reveal(_ next: Step) {
    guard next > step else {
      return
    }
    withAnimation(.easeInOut) { step = next }
  }

  func formatBirthDate(_ input: String) {
    birthDate = String(input.filter(\.isNumber).prefix(7))
  }

  /// 숫자만 추려 최대 11자리까지 010-1234-5678 형태로 포맷.
  private static func formatPhoneNumber(_ input: String) -> String {
    let digits = String(input.filter(\.isNumber).prefix(11))
    switch digits.count {
    case 0 ... 3:
      return digits
    case 4 ... 7:
      let start = digits.prefix(3)
      let rest = digits.dropFirst(3)
      return "\(start)-\(rest)"
    default:
      let start = digits.prefix(3)
      let middle = digits.dropFirst(3).prefix(4)
      let rest = digits.dropFirst(7)
      return "\(start)-\(middle)-\(rest)"
    }
  }
}

extension SignupViewModel.Focus {
  /// 실제 키보드를 띄우는 텍스트 필드 포커스. carrier 는 시트라서 키보드 포커스가 없다(nil).
  var keyboardField: SignupViewModel.Focus? {
    self == .carrier ? nil : self
  }
}
