//
//  NameField.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 이름 입력 필드.
struct NameField: View {
  @Binding var name: String
  var focus: FocusState<SignupViewModel.Focus?>.Binding

  var body: some View {
    SignupFieldContainer(label: "이름") {
      SignupTextField(
        text: $name,
        placeholder: "휴대폰 명의자 이름을 입력해 주세요.",
        focus: focus,
        focusValue: .name
      )
    }
  }
}
