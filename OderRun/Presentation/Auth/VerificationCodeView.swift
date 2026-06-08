//
//  VerificationCodeView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import Combine
import SwiftUI

/// 회원가입 본인인증 마지막 단계. 휴대폰으로 받은 인증번호 6자리를 입력한다.
struct VerificationCodeView: View {
  let onClose: () -> Void
  let onComplete: () -> Void

  @State private var viewModel: VerificationCodeViewModel

  init(
    viewModel: VerificationCodeViewModel,
    onClose: @escaping () -> Void,
    onComplete: @escaping () -> Void
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onClose = onClose
    self.onComplete = onComplete
  }

  private enum Field {
    case code
  }

  @FocusState private var focus: Field?

  /// 1초마다 남은 시간을 갱신한다.
  private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack(spacing: 0) {
      CloseHeader(title: "인증번호를 입력해 주세요", onClose: onClose)
        .padding(.top, 8)
        .padding(.bottom, 32)

      VStack(alignment: .trailing, spacing: 12) {
        SignupTextField(
          text: $viewModel.code,
          placeholder: "인증번호 6자리",
          keyboardType: .numberPad,
          focus: $focus,
          focusValue: .code,
          onChange: viewModel.inputCode
        ) {
          Text(viewModel.timerText)
            .textStyle(.inputBody1)
            .foregroundColor(.gray600)
        }

        resendButton
      }
      .padding(.horizontal, 24)

      Spacer(minLength: 0)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .ignoresSafeArea(.keyboard, edges: .bottom)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      BottomActionBar(title: "확인", isEnabled: viewModel.canProceed) {
        Task {
          if await viewModel.confirm() {
            onComplete()
          }
        }
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .onAppear { focus = .code }
    .onReceive(timer) { _ in viewModel.tick() }
  }

  private var resendButton: some View {
    Button {
      Task { await viewModel.resend() }
    } label: {
      Text("인증번호 재전송")
        .textStyle(.body2)
        .foregroundColor(.gray800)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.gray100)
        .clipShape(RoundedRectangle(cornerRadius: 4))
    }
    .buttonStyle(.plain)
  }
}

#Preview {
  VerificationCodeView(
    viewModel: VerificationCodeViewModel(
      flow: .login(phone: "01012345678"),
      sendSignupCodeUseCase: SendSignupCodeUseCase(authRepository: DIContainer.authRepository),
      confirmSignupCodeUseCase: ConfirmSignupCodeUseCase(authRepository: DIContainer.authRepository),
      sendLoginCodeUseCase: SendLoginCodeUseCase(authRepository: DIContainer.authRepository),
      confirmLoginCodeUseCase: ConfirmLoginCodeUseCase(authRepository: DIContainer.authRepository)
    ),
    onClose: {},
    onComplete: {}
  )
}
