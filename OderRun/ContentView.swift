//
//  ContentView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct ContentView: View {
  /// 로그인 진입 화면에서 분기되는 인증 경로.
  private enum AuthRoute: Hashable {
    case signup
    case verification
    case login
  }

  @State private var socialLoginViewModel = SocialLoginViewModel(
    emailLoginUseCase: EmailLoginUseCase(authRepository: DIContainer.authRepository),
    appleLoginUseCase: AppleLoginUseCase(authRepository: AuthRepository()),
    kakaoLoginUseCase: KakaoLoginUseCase(authRepository: AuthRepository())
  )
  @State private var authPath: [AuthRoute] = []

  var body: some View {
    Group {
      if socialLoginViewModel.isLoginSuccess {
        HomeView(
          viewModel: HomeViewModel(
            fetchProposalsUseCase: FetchProposalsUseCase(repository: DIContainer.proposalRepository)
          ),
          myProposalsViewModel: MyProposalsViewModel(
            fetchMyProposalsUseCase: FetchMyProposalsUseCase(repository: DIContainer.activityRepository)
          ),
          myOffersViewModel: MyOffersViewModel(
            fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.activityRepository),
            fetchProposalDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
            cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository)
          ),
          profileViewModel: ProfileViewModel(
            fetchUserDetailUseCase: FetchUserDetailUseCase(userRepository: DIContainer.userRepository),
            updateAlarmUseCase: UpdateAlarmUseCase(userRepository: DIContainer.userRepository),
            logoutUseCase: LogoutUseCase(authRepository: AuthRepository()),
            onLogout: { socialLoginViewModel.isLoginSuccess = false }
          ),
          notificationViewModel: NotificationViewModel(
            fetchNotificationsUseCase: FetchNotificationsUseCase(repository: DIContainer.notificationRepository),
            repository: DIContainer.notificationRepository
          )
        )
      } else {
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
                onComplete: { authPath.append(.verification) }
              )
            case .verification:
              VerificationCodeView(
                onClose: { authPath.removeAll() },
                onComplete: {
                  // TODO: 인증 완료 후 실제 가입/로그인 처리 연동
                  socialLoginViewModel.isLoginSuccess = true
                }
              )
            case .login:
              SmsLoginView(
                onClose: { authPath.removeAll() },
                onNext: { authPath.append(.verification) },
                onFindAccount: {
                  // TODO: 내 계정 찾기 — 회원가입과 같은 본인인증 flow 진행
                }
              )
            }
          }
        }
      }
    }
    .onReceive(NotificationCenter.default.publisher(for: .authForcedLogout)) { _ in
      socialLoginViewModel.isLoginSuccess = false
    }
  }
}

#Preview {
  ContentView()
}
