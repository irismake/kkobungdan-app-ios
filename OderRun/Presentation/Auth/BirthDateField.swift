//
//  BirthDateField.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 생년월일(주민번호 앞 6자리 + 성별 1자리) 입력 필드.
struct BirthDateField: View {
  /// 생년월일 6자리 + 성별 1자리 = 최대 7자리.
  @Binding var birthDate: String
  var focus: FocusState<SignupViewModel.Focus?>.Binding

  let onChange: (String) -> Void

  private var front: String {
    String(birthDate.prefix(6))
  }

  private var gender: String {
    String(birthDate.dropFirst(6).prefix(1))
  }

  private var isGenderEntered: Bool {
    birthDate.count >= 7
  }

  var body: some View {
    SignupFieldContainer(label: "생년월일") {
      ZStack(alignment: .leading) {
        display

        TextField("", text: Binding(
          get: { birthDate },
          set: { onChange($0) }
        ))
        .keyboardType(.numberPad)
        .focused(focus, equals: .birth)
        .foregroundColor(.clear)
        .tint(.clear)
        .frame(maxWidth: .infinity)
      }
      .contentShape(Rectangle())
      .onTapGesture { focus.wrappedValue = .birth }
      .signupFieldBox(isActive: focus.wrappedValue == .birth)
    }
  }

  private var display: some View {
    HStack(spacing: 56) {
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
}
