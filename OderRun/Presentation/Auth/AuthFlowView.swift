//
//  AuthFlowView.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import SwiftUI

/// 비로그인 상태에서 노출되는 인증 플로우(로그인·회원가입·인증번호 확인).
struct AuthFlowView: View {
  /// 로그인 진입 화면에서 분기되는 인증 경로.
  private enum AuthRoute: Hashable {
    case signup
    case verification
    case login
  }

  @Environment(SessionViewModel.self) private var session
  @State private var authPath: [AuthRoute] = []
  @State private var verificationViewModel: VerificationCodeViewModel?
  /// 인증번호 발송 API 진행 중 여부. 응답을 받을 때까지 로딩을 표시한다.
  @State private var isRequestingCode = false
  @State private var requestCodeError: String?

  var body: some View {
    NavigationStack(path: $authPath) {
      LoginView(
        onStart: { authPath.append(.signup) },
        onLogin: { authPath.append(.login) }
      )
      .navigationDestination(for: AuthRoute.self) { route in
        switch route {
        case .signup:
          SignupView(
            onClose: { authPath.removeAll() },
            onComplete: { name, phone, carrier in
              Task { await requestCode(flow: .signup(name: name, phone: phone, carrier: carrier)) }
            }
          )
        case .verification:
          if let verificationViewModel {
            VerificationCodeView(
              viewModel: verificationViewModel,
              onClose: { authPath.removeAll() },
              onComplete: {
                session.isLoggedIn = true
              }
            )
          }
        case .login:
          SmsLoginView(
            onClose: { authPath.removeAll() },
            onNext: { phone in
              Task { await requestCode(flow: .login(phone: phone)) }
            },
            onFindAccount: {
              // TODO: 내 계정 찾기 — 회원가입과 같은 본인인증 flow 진행
            }
          )
        }
      }
    }
    .overlay {
      if isRequestingCode {
        requestCodeLoadingOverlay
      }
    }
    .alert(
      "인증번호 발송 실패",
      isPresented: Binding(
        get: { requestCodeError != nil },
        set: { if !$0 {
          requestCodeError = nil
        } }
      )
    ) {
      Button("확인", role: .cancel) { requestCodeError = nil }
    } message: {
      Text(requestCodeError ?? "")
    }
  }

  @MainActor
  private func requestCode(flow: VerificationCodeViewModel.Flow) async {
    isRequestingCode = true
    let viewModel = makeVerificationViewModel(flow: flow)
    let didSend = await viewModel.sendCode()
    isRequestingCode = false

    if didSend {
      verificationViewModel = viewModel
      authPath.append(.verification)
    } else {
      requestCodeError = viewModel.errorMessage ?? "인증번호 발송에 실패했습니다. 다시 시도해주세요."
    }
  }

  private func makeVerificationViewModel(flow: VerificationCodeViewModel.Flow) -> VerificationCodeViewModel {
    VerificationCodeViewModel(
      flow: flow,
      sendSignupCodeUseCase: SendSignupCodeUseCase(authRepository: AuthRepository()),
      confirmSignupCodeUseCase: ConfirmSignupCodeUseCase(authRepository: AuthRepository()),
      sendLoginCodeUseCase: SendLoginCodeUseCase(authRepository: AuthRepository()),
      confirmLoginCodeUseCase: ConfirmLoginCodeUseCase(authRepository: AuthRepository())
    )
  }

  private var requestCodeLoadingOverlay: some View {
    ZStack {
      Color.black.opacity(0.2)
        .ignoresSafeArea()
      ProgressView()
        .padding(24)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }
}

#Preview {
  AuthFlowView()
    .environment(SessionViewModel())
}
