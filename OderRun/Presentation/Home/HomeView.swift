//
//  HomeView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct HomeView: View {
  @State private var viewModel: HomeViewModel
  @State private var selectedTab: HomeTab = .home

  private let profileViewModel: ProfileViewModel
  private let notificationViewModel: NotificationViewModel

  init(
    viewModel: HomeViewModel,
    profileViewModel: ProfileViewModel,
    notificationViewModel: NotificationViewModel
  ) {
    _viewModel = State(initialValue: viewModel)
    self.profileViewModel = profileViewModel
    self.notificationViewModel = notificationViewModel
  }

  var body: some View {
    VStack(spacing: 0) {
      tabContent

      ZStack(alignment: .topTrailing) {
        BottomNavBar(selectedTab: $selectedTab)

        if selectedTab == .home {
          FloatingActionButton {
            // TODO: 의뢰 작성 화면으로 이동
          }
          .padding(.trailing, 20)
          .offset(y: -(56 + 4))
        }
      }
    }
    .task {
      await viewModel.load()
    }
  }

  @ViewBuilder
  private var tabContent: some View {
    switch selectedTab {
    case .home:
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
                  fee: ProposalDisplay.feeString(proposal.errandFee)
                )
              }
            }
          }
          .padding(16)
        }
        .background(Color.gray000)
      }
    case .activity:
      VStack(spacing: 0) {
        TabPageHeader(title: "내 활동")
        Spacer()
          .background(Color.gray000)
      }
    case .notifications:
      NotificationView(viewModel: notificationViewModel)
    case .profile:
      ProfileView(viewModel: profileViewModel)
    }
  }
}

#Preview {
  HomeView(
    viewModel: .preview(),
    profileViewModel: .preview(),
    notificationViewModel: .preview()
  )
}
