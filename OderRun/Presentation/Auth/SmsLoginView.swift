//
//  SmsLoginView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 휴대폰 번호 로그인 진입 화면. 등록된 번호를 입력해 인증 단계로 넘어간다.
struct SmsLoginView: View {
  let onClose: () -> Void
  let onNext: () -> Void
  let onFindAccount: () -> Void

  @State private var viewModel = SmsLoginViewModel()

  private enum Field {
    case phone
  }

  @FocusState private var focus: Field?

  var body: some View {
    VStack(spacing: 0) {
      CloseHeader(title: "휴대폰 정보를 입력해 주세요", onClose: onClose)
        .padding(.top, 8)
        .padding(.bottom, 32)

      VStack(spacing: 12) {
        SignupTextField(
          text: $viewModel.phoneNumber,
          placeholder: "010-1234-5678",
          keyboardType: .numberPad,
          focus: $focus,
          focusValue: .phone,
          onChange: viewModel.inputPhoneNumber
        )

        findAccountRow
      }
      .padding(.horizontal, 24)

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      BottomActionBar(title: "다음", isEnabled: viewModel.canProceed) {
        onNext()
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .onAppear { focus = .phone }
  }

  private var findAccountRow: some View {
    HStack(spacing: 2) {
      Text("휴대폰 번호가 변경되었나요?")
        .textStyle(.caption5)
        .foregroundColor(.gray500)

      Button(action: onFindAccount) {
        Text("내 계정 찾기")
          .textStyle(.caption4)
          .foregroundColor(.indigo500)
      }
      .buttonStyle(.plain)
    }
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  SmsLoginView(onClose: {}, onNext: {}, onFindAccount: {})
}
