//
//  FocusTextField.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 외부 포커스 제어가 필요 없는 단독 사용 시 `FocusValue` 자리표시자.
enum NoFocus: Hashable { case standalone }

/// 박스 스타일 단일행 텍스트 입력 필드.
/// 라벨은 바깥 `LabeledFieldContainer` 로 붙이고, 이 컴포넌트는 입력·카운터·포커스·trailing 만 담당한다.
/// - 포커스: `focus`/`focusValue` 를 주면 화면 enum 으로 외부 제어, 안 주면 내부 포커스(+`autoFocus`).
/// - `maxLength` 를 주면 글자수 카운터 + 길이 제한.
/// - `trailing` 으로 우측 보조 뷰(타이머 등)를 둘 수 있다.
struct FocusTextField<FocusValue: Hashable, Trailing: View>: View {
  @Binding var text: String
  var placeholder: String = ""
  var keyboardType: UIKeyboardType = .default
  var maxLength: Int? = nil
  var autoFocus: Bool = false
  var focus: FocusState<FocusValue?>.Binding? = nil
  var focusValue: FocusValue? = nil
  var onChange: ((String) -> Void)? = nil
  var background: Color = .clear
  @ViewBuilder var trailing: () -> Trailing

  @FocusState private var internalFocus: Bool

  private var isActive: Bool {
    if let focus, let focusValue {
      return focus.wrappedValue == focusValue
    }
    return internalFocus
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      HStack(spacing: 8) {
        inputField
        trailing()
      }
      .textFieldBox(isActive: isActive, background: background)

      if let maxLength {
        Text("\(text.count)/\(maxLength)")
          .textStyle(.caption5)
          .foregroundColor(.gray500)
          .frame(maxWidth: .infinity, alignment: .trailing)
      }
    }
    .onAppear {
      if autoFocus {
        internalFocus = true
      }
    }
  }

  @ViewBuilder private var inputField: some View {
    let field = TextField("", text: $text)
      .textStyle(.inputBody1)
      .foregroundColor(.gray900)
      .keyboardType(keyboardType)
      .onChange(of: text) { _, newValue in
        if let maxLength, newValue.count > maxLength {
          text = String(newValue.prefix(maxLength))
        }
        onChange?(newValue)
      }
      .overlay(alignment: .leading) {
        if text.isEmpty {
          Text(placeholder)
            .textStyle(.inputBody4)
            .foregroundColor(.gray500)
            .allowsHitTesting(false)
        }
      }

    if let focus, let focusValue {
      field.focused(focus, equals: focusValue)
    } else {
      field.focused($internalFocus)
    }
  }
}

// MARK: - 편의 init

/// 외부 포커스 제어 + trailing 없는 호출용. (회원가입·계좌 등)
extension FocusTextField where Trailing == EmptyView {
  init(
    text: Binding<String>,
    placeholder: String = "",
    keyboardType: UIKeyboardType = .default,
    focus: FocusState<FocusValue?>.Binding,
    focusValue: FocusValue,
    onChange: ((String) -> Void)? = nil,
    background: Color = .clear
  ) {
    self.init(
      text: text,
      placeholder: placeholder,
      keyboardType: keyboardType,
      maxLength: nil,
      autoFocus: false,
      focus: focus,
      focusValue: focusValue,
      onChange: onChange,
      background: background,
      trailing: { EmptyView() }
    )
  }
}

/// 내부 포커스(단독 사용) + trailing 없는 호출용. (라벨/카운터만 필요한 단순 필드 — 제목·수행비·이름 등)
extension FocusTextField where FocusValue == NoFocus, Trailing == EmptyView {
  init(
    text: Binding<String>,
    placeholder: String = "",
    keyboardType: UIKeyboardType = .default,
    maxLength: Int? = nil,
    autoFocus: Bool = false,
    onChange: ((String) -> Void)? = nil,
    background: Color = .clear
  ) {
    self.init(
      text: text,
      placeholder: placeholder,
      keyboardType: keyboardType,
      maxLength: maxLength,
      autoFocus: autoFocus,
      focus: nil,
      focusValue: nil,
      onChange: onChange,
      background: background,
      trailing: { EmptyView() }
    )
  }
}
