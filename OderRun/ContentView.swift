//
//  ContentView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct ContentView: View {
  private let userRepository = DIContainer.makeUserRepository()
  private let proposalRepository = DIContainer.makeProposalRepository()
  private let offerRepository = DIContainer.makeOfferRepository()
  private let notificationRepository = DIContainer.makeNotificationRepository()

  @State private var loginViewModel: LoginViewModel

  init() {
    _loginViewModel = State(
      initialValue: LoginViewModel(
        loginUseCase: LoginUseCase(authRepository: DIContainer.makeAuthRepository())
      )
    )
  }

  var body: some View {
    if loginViewModel.isLoginSuccess {
      HomeView(
        viewModel: makeHomeViewModel(),
        profileViewModel: makeProfileViewModel(),
        notificationViewModel: makeNotificationViewModel()
      )
    } else {
      LoginView(viewModel: loginViewModel)
    }
  }

  private func makeHomeViewModel() -> HomeViewModel {
    HomeViewModel(
      fetchProposalsUseCase: FetchProposalsUseCase(repository: proposalRepository)
    )
  }

  private func makeProfileViewModel() -> ProfileViewModel {
    ProfileViewModel(
      fetchUserDetailUseCase: FetchUserDetailUseCase(userRepository: userRepository),
      updateAlarmUseCase: UpdateAlarmUseCase(userRepository: userRepository),
      userRepository: userRepository
    )
  }

  private func makeNotificationViewModel() -> NotificationViewModel {
    NotificationViewModel(
      fetchNotificationsUseCase: FetchNotificationsUseCase(repository: notificationRepository),
      repository: notificationRepository
    )
  }
}

#Preview {
  ContentView()
}
