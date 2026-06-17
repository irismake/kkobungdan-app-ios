//
//  HomeContainerView.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import SwiftUI

struct HomeContainerView: View {
  @Environment(SessionViewModel.self) private var session

  var body: some View {
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
        logoutUseCase: LogoutUseCase(authRepository: DIContainer.authRepository),
        onLogout: { session.isLoggedIn = false }
      ),
      notificationViewModel: NotificationViewModel(
        fetchNotificationsUseCase: FetchNotificationsUseCase(repository: DIContainer.notificationRepository),
        repository: DIContainer.notificationRepository
      )
    )
  }
}

#Preview {
  HomeContainerView()
    .environment(SessionViewModel())
}
