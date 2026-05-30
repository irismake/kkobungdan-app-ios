//
//  SignupField.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

extension View {
  /// 회원가입 입력 필드의 공통 박스 스타일(둥근 테두리 + 활성 시 indigo 강조).
  func signupFieldBox(isActive: Bool) -> some View {
    padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(isActive ? Color.indigo500 : Color.gray200, lineWidth: 1)
      )
  }
}

/// 라벨 + 입력 컨트롤을 묶는 공통 레이아웃.
struct SignupFieldContainer<Content: View>: View {
  let label: String
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .textStyle(.body2)
        .foregroundColor(.gray800)

      content()
    }
    .padding(.horizontal, 16)
  }
}

/// 박스 스타일 + 포커스 강조를 갖춘 공통 텍스트 입력 필드.
/// 회원가입(이름·휴대폰)과 인증번호 입력에서 공용으로 사용한다.
/// `focusValue` 와 `focus` 로 화면별 @FocusState 에 연결하고, `trailing` 으로 우측 보조 뷰(타이머 등)를 둘 수 있다.
struct SignupTextField<FocusValue: Hashable, Trailing: View>: View {
  @Binding var text: String
  var placeholder: String = ""
  var keyboardType: UIKeyboardType = .default
  var focus: FocusState<FocusValue?>.Binding
  var focusValue: FocusValue
  var onChange: ((String) -> Void)?
  @ViewBuilder var trailing: () -> Trailing

  var body: some View {
    HStack(spacing: 8) {
      TextField(placeholder, text: $text)
        .textStyle(.inputBody1)
        .foregroundColor(.gray900)
        .keyboardType(keyboardType)
        .focused(focus, equals: focusValue)
        .onChange(of: text) { _, newValue in onChange?(newValue) }

      trailing()
    }
    .signupFieldBox(isActive: focus.wrappedValue == focusValue)
  }
}

extension SignupTextField where Trailing == EmptyView {
  init(
    text: Binding<String>,
    placeholder: String = "",
    keyboardType: UIKeyboardType = .default,
    focus: FocusState<FocusValue?>.Binding,
    focusValue: FocusValue,
    onChange: ((String) -> Void)? = nil
  ) {
    self.init(
      text: text,
      placeholder: placeholder,
      keyboardType: keyboardType,
      focus: focus,
      focusValue: focusValue,
      onChange: onChange,
      trailing: { EmptyView() }
    )
  }
}
