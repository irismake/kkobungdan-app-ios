//
//  HomeView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct HomeView: View {
  @State private var viewModel: HomeViewModel
  @State private var activityViewModel: ActivityViewModel
  @State private var selectedTab: HomeTab = .home

  @State private var homePath: [AppRoute] = []
  @State private var activityPath: [AppRoute] = []

  private let profileViewModel: ProfileViewModel
  private let notificationViewModel: NotificationViewModel

  init(
    viewModel: HomeViewModel,
    activityViewModel: ActivityViewModel,
    profileViewModel: ProfileViewModel,
    notificationViewModel: NotificationViewModel
  ) {
    _viewModel = State(initialValue: viewModel)
    _activityViewModel = State(initialValue: activityViewModel)
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
          homeRoot
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
            await activityViewModel.load()
          }
        }
      }
    case .activity:
      NavigationStack(path: $activityPath) {
        VStack(spacing: 0) {
          ActivityView(
            viewModel: activityViewModel,
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
          Task { await activityViewModel.load() }
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

  private var homeRoot: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "홈")
      ScrollView {
        VStack(spacing: 12) {
          if viewModel.isLoading, viewModel.proposals.isEmpty {
            ProgressView()
              .padding(.top, 40)
          } else if let errorMessage = viewModel.errorMessage, viewModel.proposals.isEmpty {
            Text(errorMessage)
              .textStyle(.body3)
              .foregroundColor(Color.rose500)
              .padding(.top, 40)
          } else {
            ForEach(viewModel.proposals) { proposal in
              ProposalCard(
                title: proposal.title,
                description: proposal.content,
                date: ProposalDisplay.dateString(proposal.deadline),
                time: ProposalDisplay.timeString(proposal.deadline),
                fee: ProposalDisplay.feeString(proposal.errandFee),
                badges: ProposalDisplay.badges(proposal: proposal)
              )
              .contentShape(Rectangle())
              .onTapGesture {
                handleProposalTap(proposal)
              }
            }
          }
        }
        .padding(16)
      }
      .background(Color.gray000)
      .refreshable {
        await viewModel.load()
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
            await activityViewModel.load()
          }
        }
      )
      .navigationBarBackButtonHidden(true)
    }
  }

  private func popLast(path: Binding<[AppRoute]>) {
    if !path.wrappedValue.isEmpty {
      path.wrappedValue.removeLast()
    }
  }

  // MARK: - Actions

  private func handleProposalTap(_ proposal: Proposal) {
    if proposal.ordererID == DummySession.currentUserID {
      homePath.append(.myProposalDetail(proposalID: proposal.id))
    } else {
      homePath.append(.proposalDetail(proposalID: proposal.id))
    }
  }
}

#Preview {
  HomeView(
    viewModel: .preview(),
    activityViewModel: .preview(),
    profileViewModel: .preview(),
    notificationViewModel: .preview()
  )
}
