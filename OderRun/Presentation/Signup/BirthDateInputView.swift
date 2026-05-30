//
//  BirthDateInputView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 본인인증 플로우 4단계 — 생년월일(주민번호 앞 6자리 + 성별 1자리) 입력.
struct BirthDateInputView: View {
  /// 생년월일 6자리 + 성별 1자리 = 최대 7자리.
  @Binding var birthDate: String
  let name: String
  let carrier: String
  let phoneNumber: String
  let onClose: () -> Void
  let onNext: () -> Void

  @FocusState private var isFocused: Bool

  private var isValid: Bool {
    birthDate.count == 7
  }

  private var front: String {
    String(birthDate.prefix(6))
  }

  private var isGenderEntered: Bool {
    birthDate.count >= 7
  }

  var body: some View {
    VStack(spacing: 0) {
      VStack(spacing: 32) {
        header

        birthField

        nameField

        carrierField

        phoneField
      }
      .padding(.top, 8)

      Spacer()

      BottomActionBar(title: "다음", isEnabled: isValid, action: onNext)
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

      Text("생년월일을 입력해주세요")
        .textStyle(.heading3)
        .foregroundColor(.gray900)

      Spacer(minLength: 0)
    }
    .padding(.leading, 8)
  }

  private var birthField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("생년월일")
        .textStyle(.body2)
        .foregroundColor(.gray800)

      ZStack(alignment: .leading) {
        birthDisplay

        TextField("", text: Binding(
          get: { birthDate },
          set: { birthDate = String($0.filter(\.isNumber).prefix(7)) }
        ))
        .keyboardType(.numberPad)
        .focused($isFocused)
        .foregroundColor(.clear)
        .tint(.clear)
        .frame(maxWidth: .infinity)
      }
      .contentShape(Rectangle())
      .onTapGesture { isFocused = true }
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

  private var gender: String {
    String(birthDate.dropFirst(6).prefix(1))
  }

  private var birthDisplay: some View {
    HStack(spacing: 56) {
      // 숨김 플레이스홀더로 폭을 고정해 입력 시 대시·점이 움직이지 않게 한다.
      ZStack(alignment: .leading) {
        Text("생년월일").textStyle(.inputBody1).hidden()

        Text(front.isEmpty ? "생년월일" : front)
          .textStyle(.inputBody1)
          .foregroundColor(front.isEmpty ? .gray500 : .gray900)
      }

      Text("-")
        .textStyle(.inputBody1)
        .foregroundColor(.gray500)

      HStack(spacing: 6) {
        // 성별 자리: 입력 전 light dot, 입력 후 숫자. 폭은 숫자 기준 고정.
        ZStack {
          Text("0").textStyle(.inputBody1).hidden()

          if isGenderEntered {
            Text(gender)
              .textStyle(.inputBody1)
              .foregroundColor(.gray900)
          } else {
            Circle()
              .fill(Color.gray300)
              .frame(width: 6, height: 6)
          }
        }

        ForEach(0 ..< 6, id: \.self) { _ in
          Circle()
            .fill(Color.gray900)
            .frame(width: 6, height: 6)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var nameField: some View {
    readonlyField(label: "이름", value: name)
  }

  private var phoneField: some View {
    readonlyField(label: "휴대폰 번호", value: phoneNumber)
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

  private func readonlyField(label: String, value: String) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .textStyle(.body2)
        .foregroundColor(.gray800)

      HStack(spacing: 0) {
        Text(value)
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
  BirthDateInputView(
    birthDate: .constant(""),
    name: "홍길동",
    carrier: "LG U+ 알뜰폰",
    phoneNumber: "010-2323-4545",
    onClose: {},
    onNext: {}
  )
}
