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
  @State private var selectedTab: HomeTab = .home

  @State private var homePath: [AppRoute] = []
  @State private var activityPath: [AppRoute] = []

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
    switch selectedTab {
    case .home:
      NavigationStack(path: $homePath) {
        VStack(spacing: 0) {
          HomeView(
            viewModel: viewModel,
            onSelectProposal: { proposal in
              homePath.append(.proposalDetail(proposalID: proposal.id))
            }
          )
          bottomBar
        }
        .navigationDestination(for: AppRoute.self) { route in
          destination(for: route, path: $homePath)
        }
      }
      .onChange(of: homePath) { _, newPath in
        if newPath.isEmpty {
          Task {
            await viewModel.load()
            await myProposalsViewModel.load()
            await myOffersViewModel.load()
          }
        }
      }
    case .activity:
      NavigationStack(path: $activityPath) {
        VStack(spacing: 0) {
          ActivityView(
            proposalsViewModel: myProposalsViewModel,
            offersViewModel: myOffersViewModel,
            onSelectOrdererProposal: { proposalID in
              activityPath.append(.myProposalDetail(proposalID: proposalID))
            },
            onSelectRunnerItem: { proposalID, offerID in
              activityPath.append(.runnerApplyDetail(proposalID: proposalID, offerID: offerID))
            }
          )
          bottomBar
        }
        .navigationDestination(for: AppRoute.self) { route in
          destination(for: route, path: $activityPath)
        }
      }
      .onChange(of: activityPath) { _, newPath in
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
      BottomNavBar(selectedTab: $selectedTab)

      if selectedTab == .home {
        FloatingActionButton {
          homePath.append(.addProposalDraft)
        }
        .padding(.trailing, 20)
        .offset(y: -(56 + 4))
      }
    }
  }

  // MARK: - Routing

  @ViewBuilder
  private func destination(for route: AppRoute, path: Binding<[AppRoute]>) -> some View {
    switch route {
    case let .proposalDetail(proposalID):
      ProposalDetailView(
        viewModel: AppRouteFactory.makeProposalDetailViewModel(proposalID: proposalID),
        onBack: { popLast(path: path) },
        onApply: {
          path.wrappedValue.append(.accountRegister(proposalID: proposalID))
        },
        onMine: {
          // 홈에서 탭한 요청이 내 요청이면 내 요청 상세로 라우트를 교체한다.
          if !path.wrappedValue.isEmpty {
            path.wrappedValue[path.wrappedValue.count - 1] = .myProposalDetail(proposalID: proposalID)
          }
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .accountRegister(proposalID):
      AccountRegisterView(
        viewModel: AppRouteFactory.makeAccountRegisterViewModel(proposalID: proposalID),
        onBack: { popLast(path: path) },
        onApplied: {
          path.wrappedValue.append(.applyComplete(proposalID: proposalID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case .applyComplete:
      ApplyCompleteView(
        onConfirm: {
          path.wrappedValue.removeAll()
        },
        onViewHistory: {
          // home segment 에는 offer 가 보이는 곳이 없으므로 activity 탭으로 보낸다.
          // 거기서 본인 offer 카드를 탭하면 `.runnerApplyDetail(proposalID:offerID:)` 로 진입.
          path.wrappedValue.removeAll()
          selectedTab = .activity
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .myProposalDetail(proposalID):
      MyProposalDetailView(
        viewModel: AppRouteFactory.makeMyProposalDetailViewModel(proposalID: proposalID),
        onBack: { popLast(path: path) },
        onShowApplicants: {
          path.wrappedValue.append(.applicantList(proposalID: proposalID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .runnerApplyDetail(proposalID, offerID):
      ApplyDetailView(
        viewModel: AppRouteFactory.makeApplyDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { popLast(path: path) }
      )
      .navigationBarBackButtonHidden(true)
    case let .applicantOfferDetail(proposalID, offerID):
      ApplyDetailView(
        viewModel: AppRouteFactory.makeApplyDetailViewModel(
          proposalID: proposalID,
          offerID: offerID
        ),
        onBack: { popLast(path: path) }
      )
      .navigationBarBackButtonHidden(true)
    case let .applicantList(proposalID):
      ApplicantListView(
        viewModel: AppRouteFactory.makeApplicantListViewModel(proposalID: proposalID),
        onBack: { popLast(path: path) },
        onAccepted: {
          path.wrappedValue = [.myProposalDetail(proposalID: proposalID)]
        },
        onSelectApplicant: { proposalID, offerID in
          path.wrappedValue.append(.applicantOfferDetail(proposalID: proposalID, offerID: offerID))
        }
      )
      .navigationBarBackButtonHidden(true)
    case .addProposalDraft, .addProposalDateTime, .addProposalFee:
      addProposalDestination(for: route, path: path)
    }
  }

  /// 새 의뢰 작성(3단계) 라우팅. `destination(for:path:)` 길이 분산을 위해 분리.
  @ViewBuilder
  private func addProposalDestination(for route: AppRoute, path: Binding<[AppRoute]>) -> some View {
    switch route {
    case .addProposalDraft:
      AddProposalView(
        onBack: { popLast(path: path) },
        onNext: { draft in
          path.wrappedValue.append(.addProposalDateTime(draft: draft))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .addProposalDateTime(draft):
      AddProposalDateTimeView(
        draft: draft,
        onBack: { popLast(path: path) },
        onNext: { updated in
          path.wrappedValue.append(.addProposalFee(draft: updated))
        }
      )
      .navigationBarBackButtonHidden(true)
    case let .addProposalFee(draft):
      AddProposalFeeView(
        draft: draft,
        viewModel: AppRouteFactory.makeAddProposalViewModel(),
        onBack: { popLast(path: path) },
        onCreated: { proposal in
          path.wrappedValue = [.myProposalDetail(proposalID: proposal.id)]
          Task {
            await viewModel.load()
            await myProposalsViewModel.load()
            await myOffersViewModel.load()
          }
        }
      )
      .navigationBarBackButtonHidden(true)
    default:
      EmptyView()
    }
  }

  private func popLast(path: Binding<[AppRoute]>) {
    if !path.wrappedValue.isEmpty {
      path.wrappedValue.removeLast()
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
