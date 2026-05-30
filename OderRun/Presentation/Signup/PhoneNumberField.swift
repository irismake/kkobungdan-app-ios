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
      TextField("010-1234-5678", text: $phoneNumber)
        .textStyle(.inputBody1)
        .foregroundColor(.gray900)
        .keyboardType(.numberPad)
        .focused(focus, equals: .phone)
        .onChange(of: phoneNumber) { _, newValue in onChange(newValue) }
        .signupFieldBox(isActive: focus.wrappedValue == .phone)
    }
  }
}
