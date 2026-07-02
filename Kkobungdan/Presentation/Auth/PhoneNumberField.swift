//
//  PhoneNumberField.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 휴대폰 번호 입력 필드.
struct PhoneNumberField: View {
  @Binding var phoneNumber: String
  var focus: FocusState<SignupViewModel.Focus?>.Binding
  let onChange: (String) -> Void

  var body: some View {
    // 라벨 없음 — 헤더("휴대폰 정보를 입력해 주세요")가 안내하므로 인증번호 필드와 동일하게 라벨 생략.
    FocusTextField(
      text: $phoneNumber,
      placeholder: "010-1234-5678",
      keyboardType: .numberPad,
      focus: focus,
      focusValue: .phone,
      onChange: onChange
    )
  }
}
