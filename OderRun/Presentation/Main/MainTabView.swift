//
//  MainTabView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

/// 로그인 후 진입점이자 메인 탭 셸(홈·내 활동·알림·프로필).
/// DIContainer 로 탭 루트 VM 을 조립한다. (비로그인 진입점 `AuthFlowView` 와 대칭)
struct MainTabView: View {
  @State private var viewModel: HomeViewModel
  @State private var myProposalsViewModel: MyProposalsViewModel
  @State private var myOffersViewModel: MyOffersViewModel
  @State private var router = AppRouter()

  private let profileViewModel: ProfileViewModel
  private let notificationViewModel: NotificationViewModel

  /// 운영 진입점. DIContainer 로 탭 루트 VM 을 조립한다.
  init() {
    self.init(
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
        logoutUseCase: LogoutUseCase(authRepository: DIContainer.authRepository)
      ),
      notificationViewModel: NotificationViewModel(
        fetchNotificationsUseCase: FetchNotificationsUseCase(repository: DIContainer.notificationRepository),
        repository: DIContainer.notificationRepository
      )
    )
  }

  /// 프리뷰·테스트용 VM 주입 진입점.
  init(
    viewModel: HomeViewModel,
    myProposalsViewModel: MyProposalsViewModel,
    myOffersViewModel: MyOffersViewModel,
    profileViewModel: ProfileViewModel,
    notificationViewModel: NotificationViewModel
  ) {
    _viewModel = State(initialValue: viewModel)
    _myProposalsViewModel = State(initialValue: myProposalsViewModel)
    _myOffersViewModel = State(initialValue: myOffersViewModel)
    self.profileViewModel = profileViewModel
    self.notificationViewModel = notificationViewModel
  }

  var body: some View {
    tabContent
      .task {
        await viewModel.load()
      }
  }

  // MARK: - Tab Content

  @ViewBuilder
  private var tabContent: some View {
    switch router.selectedTab {
    case .home:
      NavigationStack(path: $router.homePath) {
        VStack(spacing: 0) {
          HomeView(
            viewModel: viewModel,
            onSelectProposal: { proposal in
              router.homePath.append(.proposalDetail(proposalID: proposal.id))
            }
          )
          bottomBar
        }
        .navigationDestination(for: AppRoute.self) { route in
          router.destination(for: route, path: $router.homePath)
        }
      }
      .onChange(of: router.homePath) { _, newPath in
        if newPath.isEmpty {
          Task {
            await viewModel.load()
            await myProposalsViewModel.load()
            await myOffersViewModel.load()
          }
        }
      }
    case .activity:
      NavigationStack(path: $router.activityPath) {
        VStack(spacing: 0) {
          ActivityView(
            proposalsViewModel: myProposalsViewModel,
            offersViewModel: myOffersViewModel,
            onSelectOrdererProposal: { proposalID in
              router.activityPath.append(.myProposalDetail(proposalID: proposalID))
            },
            onSelectRunnerItem: { proposalID, offerID in
              router.activityPath.append(.offerDetail(proposalID: proposalID, offerID: offerID))
            }
          )
          bottomBar
        }
        .navigationDestination(for: AppRoute.self) { route in
          router.destination(for: route, path: $router.activityPath)
        }
      }
      .onChange(of: router.activityPath) { _, newPath in
        if newPath.isEmpty {
          Task {
            await viewModel.load()
          }
        }
      }
    case .notifications:
      VStack(spacing: 0) {
        NotificationView(viewModel: notificationViewModel)
        bottomBar
      }
    case .profile:
      VStack(spacing: 0) {
        ProfileView(viewModel: profileViewModel)
        bottomBar
      }
    }
  }

  private var bottomBar: some View {
    ZStack(alignment: .topTrailing) {
      BottomNavBar(selectedTab: $router.selectedTab)

      if router.selectedTab == .home {
        FloatingActionButton {
          router.homePath.append(.addProposalDraft)
        }
        .padding(.trailing, 20)
        .offset(y: -(56 + 4))
      }
    }
  }
}

#Preview {
  MainTabView(
    viewModel: .preview(),
    myProposalsViewModel: .preview(),
    myOffersViewModel: .preview(),
    profileViewModel: .preview(),
    notificationViewModel: .preview()
  )
}
