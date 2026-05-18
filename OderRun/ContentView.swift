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
    appleLoginUseCase: AppleLoginUseCase(authRepository: DIContainer.authRepository),
    kakaoLoginUseCase: KakaoLoginUseCase(authRepository: DIContainer.authRepository)
  )

  var body: some View {
    if loginViewModel.isLoginSuccess {
      HomeView(
        viewModel: HomeViewModel(
          fetchProposalsUseCase: FetchProposalsUseCase(repository: DIContainer.proposalRepository)
        ),
        activityViewModel: ActivityViewModel(
          fetchMyProposalsUseCase: FetchMyProposalsUseCase(repository: DIContainer.activityRepository),
          fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.activityRepository),
          cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository)
        ),
        profileViewModel: ProfileViewModel(
          fetchUserDetailUseCase: FetchUserDetailUseCase(userRepository: DIContainer.userRepository),
          updateAlarmUseCase: UpdateAlarmUseCase(userRepository: DIContainer.userRepository),
          userRepository: DIContainer.userRepository
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
