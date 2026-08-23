//
//  SmsLoginViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 휴대폰 번호 로그인 진입 화면 상태. 번호 11자리가 채워지면 다음으로 진행할 수 있다.
@Observable
final class SmsLoginViewModel {
  var phoneNumber: String = ""

  var canProceed: Bool {
    phoneNumber.filter(\.isNumber).count == 11
  }

  /// 입력값을 010-1234-5678 형태로 포맷한다.
  func inputPhoneNumber(_ input: String) {
    let formatted = input.formattedKoreanPhoneNumber
    if formatted != phoneNumber {
      phoneNumber = formatted
    }
  }
}
