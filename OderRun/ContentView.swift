//
//  ContentView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct ContentView: View {
  private let userRepository: UserRepositoryProtocol = UserRepositoryImpl()
  private let proposalRepository: ProposalRepositoryProtocol = ProposalRepositoryImpl()
  private let offerRepository: OfferRepositoryProtocol = OfferRepositoryImpl()
  private let missionRepository: MissionRepositoryProtocol = MissionRepositoryImpl()
  private let notificationRepository: NotificationRepositoryProtocol = NotificationRepositoryImpl()

  @State private var loginViewModel: LoginViewModel

  init() {
    let authRepository = AuthRepositoryImpl()
    _loginViewModel = State(
      initialValue: LoginViewModel(loginUseCase: LoginUseCase(authRepository: authRepository))
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
