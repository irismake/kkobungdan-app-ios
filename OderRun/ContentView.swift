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
              SignupView(onClose: { authPath.removeAll() })
            case .login:
              // TODO: 로그인 전용 화면으로 교체
              SocialLoginView(viewModel: socialLoginViewModel)
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
