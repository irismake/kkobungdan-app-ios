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
    case verification(VerificationCodeViewModel.Flow)
    case login
  }

  @Environment(SessionViewModel.self) private var session
  @State private var authPath: [AuthRoute] = []

  var body: some View {
    Group {
      if session.isLoggedIn {
        HomeView(
          viewModel: HomeViewModel(
            fetchProposalsUseCase: FetchProposalsUseCase(repository: DIContainer.proposalRepository)
          ),
          myProposalsViewModel: MyProposalsViewModel(
            fetchMyProposalsUseCase: FetchMyProposalsUseCase(repository: DIContainer.activityRepository)
          ),
          myOffersViewModel: MyOffersViewModel(
            fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.activityRepository),
            fetchProposalDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository)
          ),
          profileViewModel: ProfileViewModel(
            fetchUserDetailUseCase: FetchUserDetailUseCase(userRepository: DIContainer.userRepository),
            updateAlarmUseCase: UpdateAlarmUseCase(userRepository: DIContainer.userRepository),
            logoutUseCase: LogoutUseCase(authRepository: AuthRepository()),
            onLogout: { session.isLoggedIn = false }
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
                onComplete: { name, phone, carrier in
                  authPath.append(.verification(.signup(name: name, phone: phone, carrier: carrier)))
                }
              )
            case let .verification(flow):
              VerificationCodeView(
                viewModel: VerificationCodeViewModel(
                  flow: flow,
                  sendSignupCodeUseCase: SendSignupCodeUseCase(authRepository: AuthRepository()),
                  confirmSignupCodeUseCase: ConfirmSignupCodeUseCase(authRepository: AuthRepository()),
                  sendLoginCodeUseCase: SendLoginCodeUseCase(authRepository: AuthRepository()),
                  confirmLoginCodeUseCase: ConfirmLoginCodeUseCase(authRepository: AuthRepository())
                ),
                onClose: { authPath.removeAll() },
                onComplete: {
                  session.isLoggedIn = true
                }
              )
            case .login:
              SmsLoginView(
                onClose: { authPath.removeAll() },
                onNext: { phone in authPath.append(.verification(.login(phone: phone))) },
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
      session.isLoggedIn = false
    }
  }
}

#Preview {
  ContentView()
    .environment(SessionViewModel())
}
