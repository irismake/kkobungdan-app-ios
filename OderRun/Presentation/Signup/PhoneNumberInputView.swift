//
//  PhoneNumberInputView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 본인인증 플로우 1단계 — 휴대폰 번호 입력.
struct PhoneNumberInputView: View {
  let onClose: () -> Void
  let onNext: (String) -> Void

  @State private var phoneNumber: String = ""
  @FocusState private var isFocused: Bool

  var body: some View {
    VStack(spacing: 32) {
      header

      phoneField
        .padding(.horizontal, 24)

      Spacer()
    }
    .padding(.top, 8)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .contentShape(Rectangle())
    .onTapGesture { isFocused = false }
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .onAppear { isFocused = true }
  }

  private var header: some View {
    HStack(spacing: 8) {
      Button(action: onClose) {
        Image("icon_close")
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .padding(8)
      }

      Text("휴대폰 정보를 입력해 주세요")
        .textStyle(.heading3)
        .foregroundColor(.gray900)

      Spacer(minLength: 0)
    }
    .padding(.leading, 8)
  }

  private var phoneField: some View {
    TextField("010-1234-5678", text: $phoneNumber)
      .textStyle(.inputBody1)
      .foregroundColor(.gray900)
      .keyboardType(.numberPad)
      .focused($isFocused)
      .onChange(of: phoneNumber) { _, newValue in
        let formatted = Self.formatPhoneNumber(newValue)
        if formatted != phoneNumber {
          phoneNumber = formatted
        }
        if formatted.filter(\.isNumber).count == 11 {
          isFocused = false
          onNext(formatted)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(isFocused ? Color.indigo500 : Color.gray200, lineWidth: 1)
      )
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

#Preview {
  PhoneNumberInputView(onClose: {}, onNext: { _ in })
}
