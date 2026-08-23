//
//  MainTabView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

/// 로그인 후 진입점이자 메인 탭 셸(홈·내 활동·알림·프로필).
/// DIContainer 로 탭 루트 VM 을 조립한다. (비로그인 진입점 `AuthFlowView` 와 대칭)
struct MainTabView: View {
  @Environment(\.scenePhase) private var scenePhase
  @State private var viewModel: HomeViewModel
  @State private var myProposalsViewModel: MyProposalsViewModel
  @State private var myOffersViewModel: MyOffersViewModel
  @State private var router = AppRouter()

  @State private var profileViewModel: ProfileViewModel
  @State private var withdrawReasonViewModel: WithdrawReasonViewModel
  @State private var notificationViewModel: NotificationViewModel

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
        updateUserNameUseCase: UpdateUserNameUseCase(userRepository: DIContainer.userRepository),
        logoutUseCase: LogoutUseCase(authRepository: DIContainer.authRepository)
      ),
      withdrawReasonViewModel: WithdrawReasonViewModel(
        fetchReasonsUseCase: FetchWithdrawalReasonsUseCase(userRepository: DIContainer.userRepository),
        withdrawUseCase: WithdrawUserUseCase(userRepository: DIContainer.userRepository)
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
    withdrawReasonViewModel: WithdrawReasonViewModel,
    notificationViewModel: NotificationViewModel
  ) {
    _viewModel = State(initialValue: viewModel)
    _myProposalsViewModel = State(initialValue: myProposalsViewModel)
    _myOffersViewModel = State(initialValue: myOffersViewModel)
    _profileViewModel = State(initialValue: profileViewModel)
    _withdrawReasonViewModel = State(initialValue: withdrawReasonViewModel)
    _notificationViewModel = State(initialValue: notificationViewModel)
  }

  var body: some View {
    tabContent
      .task {
        await viewModel.load()
      }
      // 푸시 배너 탭 딥링크 소비.
      .task(id: PushRouteStore.shared.pending) {
        guard let payload = PushRouteStore.shared.pending else {
          return
        }
        PushRouteStore.shared.pending = nil
        await router.route(push: payload)
      }
      // 최초 진입 + 포그라운드 푸시 도착 시 안읽음 뱃지를 갱신한다.
      .task(id: PushRouteStore.shared.foregroundPushCount) {
        await notificationViewModel.refreshUnreadCount()
        if PushRouteStore.shared.foregroundPushCount > 0 {
          await refreshRootData()
        }
      }
      // 백그라운드에 쌓인 알림 반영: 앱이 다시 활성화될 때 뱃지 갱신
      .onChange(of: scenePhase) { _, phase in
        if phase == .active {
          Task {
            await notificationViewModel.refreshUnreadCount()
            await refreshRootData()
          }
        }
      }
      .onReceive(NotificationCenter.default.publisher(for: .proposalListNeedsRefresh)) { _ in
        Task { await refreshRootData() }
      }
  }

  @MainActor
  private func refreshRootData() async {
    await viewModel.load()
    await myProposalsViewModel.load(status: router.activityFilter.proposalStatuses)
    await myOffersViewModel.load(status: router.activityFilter.offerStatuses)
  }

  // MARK: - Tab Content

  @ViewBuilder
  private var tabContent: some View {
    switch router.selectedTab {
    case .home:
      NavigationStack(path: $router.homePath) {
        HomeView(
          viewModel: viewModel,
          onSelectProposal: { proposal in
            router.homePath.append(.proposalDetail(proposalID: proposal.id))
          }
        )
        .safeAreaInset(edge: .bottom, spacing: 0) {
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
        ActivityView(
          proposalsViewModel: myProposalsViewModel,
          offersViewModel: myOffersViewModel,
          segment: $router.activitySegment,
          filter: $router.activityFilter,
          onSelectOrdererProposal: { proposalID in
            router.activityPath.append(.myProposalDetail(proposalID: proposalID))
          },
          onSelectRunnerItem: { proposalID, offerID in
            router.activityPath.append(.offerDetail(proposalID: proposalID, offerID: offerID))
          }
        )
        .safeAreaInset(edge: .bottom, spacing: 0) {
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
      NotificationView(
        viewModel: notificationViewModel,
        onSelect: { payload in
          Task { await router.route(push: payload) }
        }
      )
      .safeAreaInset(edge: .bottom, spacing: 0) {
        bottomBar
      }
    case .profile:
      NavigationStack {
        ProfileView(
          viewModel: profileViewModel,
          withdrawReasonViewModel: withdrawReasonViewModel
        )
        .safeAreaInset(edge: .bottom, spacing: 0) {
          bottomBar
        }
      }
    }
  }

  private var bottomBar: some View {
    ZStack(alignment: .topTrailing) {
      BottomNavBar(
        selectedTab: $router.selectedTab,
        unreadCount: notificationViewModel.unreadCount
      )

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
    withdrawReasonViewModel: .preview(),
    notificationViewModel: .preview()
  )
}
