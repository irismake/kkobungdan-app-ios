//
//  PhoneNumberField.swift
//  OderRun
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
    SignupFieldContainer(label: "휴대폰 번호") {
      SignupTextField(
        text: $phoneNumber,
        placeholder: "010-1234-5678",
        keyboardType: .numberPad,
        focus: focus,
        focusValue: .phone,
        onChange: onChange
      )
    }
  }
}
