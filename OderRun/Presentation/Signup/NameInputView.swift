//
//  NameInputView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 본인인증 플로우 3단계 — 이름 입력.
struct NameInputView: View {
  @Binding var name: String
  let carrier: String
  let phoneNumber: String
  let onClose: () -> Void
  let onNext: () -> Void

  @FocusState private var isFocused: Bool

  private var isNameValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 32) {
        header

        nameField

        carrierField

        phoneField
      }
      .padding(.top, 8)

      Spacer()

      BottomActionBar(title: "다음", isEnabled: isNameValid, action: onNext)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
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

      Text("이름을 입력해주세요")
        .textStyle(.heading3)
        .foregroundColor(.gray900)

      Spacer(minLength: 0)
    }
    .padding(.leading, 8)
  }

  private var nameField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("이름")
        .textStyle(.body2)
        .foregroundColor(.gray800)

      TextField("휴대폰 명의자 이름을 입력해 주세요.", text: $name)
        .textStyle(.inputBody1)
        .foregroundColor(.gray900)
        .focused($isFocused)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(isFocused ? Color.indigo500 : Color.gray200, lineWidth: 1)
        )
    }
    .padding(.horizontal, 16)
  }

  private var carrierField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("통신사")
        .textStyle(.body2)
        .foregroundColor(.gray800)

      HStack(spacing: 0) {
        Text(carrier)
          .textStyle(.inputBody1)
          .foregroundColor(.gray900)

        Spacer(minLength: 0)

        Image("icon_arrow_down")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 24, height: 24)
          .foregroundColor(Color.gray600)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.gray200, lineWidth: 1)
      )
    }
    .padding(.horizontal, 16)
  }

  private var phoneField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("휴대폰 번호")
        .textStyle(.body2)
        .foregroundColor(.gray800)

      HStack(spacing: 0) {
        Text(phoneNumber)
          .textStyle(.inputBody1)
          .foregroundColor(.gray900)

        Spacer(minLength: 0)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(Color.gray200, lineWidth: 1)
      )
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  NameInputView(
    name: .constant(""),
    carrier: "LG U+ 알뜰폰",
    phoneNumber: "010-2323-4545",
    onClose: {},
    onNext: {}
  )
}
