//
//  ContentView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct ContentView: View {
  @State private var loginViewModel = LoginViewModel(
    loginUseCase: LoginUseCase(authRepository: DIContainer.authRepository),
    appleLoginUseCase: AppleLoginUseCase(authRepository: AuthRepository()),
    kakaoLoginUseCase: KakaoLoginUseCase(authRepository: AuthRepository())
  )

  var body: some View {
    if loginViewModel.isLoginSuccess {
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
          onLogout: { loginViewModel.isLoginSuccess = false }
        ),
        notificationViewModel: NotificationViewModel(
          fetchNotificationsUseCase: FetchNotificationsUseCase(repository: DIContainer.notificationRepository),
          repository: DIContainer.notificationRepository
        )
      )
    } else {
      LoginView(viewModel: loginViewModel)
    }
  }
}

#Preview {
  ContentView()
}
