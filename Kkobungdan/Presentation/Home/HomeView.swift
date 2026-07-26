//
//  HomeView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

/// 메인 탭의 '홈' 세그먼트. 전체 의뢰 목록을 보여주고, 카드 탭을 상위(`MainTabView`)에 전달한다.
struct HomeView: View {
  @State private var viewModel: HomeViewModel

  var onSelectProposal: (Proposal) -> Void = { _ in }

  init(
    viewModel: HomeViewModel,
    onSelectProposal: @escaping (Proposal) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onSelectProposal = onSelectProposal
  }

  var body: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "홈")
      ScrollView {
        VStack(spacing: 12) {
          if viewModel.isLoading, viewModel.proposals.isEmpty {
            ProgressView()
              .padding(.top, 40)
              .frame(maxWidth: .infinity)
          } else {
            ForEach(viewModel.proposals) { proposal in
              ProposalCard(
                title: proposal.title,
                description: proposal.content,
                date: DisplayFormatter.dateString(proposal.deadline),
                time: DisplayFormatter.timeString(proposal.deadline),
                fee: DisplayFormatter.feeString(proposal.errandFee),
                badges: ActivityStatusBadge.badges(proposal: proposal)
              )
              .contentShape(Rectangle())
              .onTapGesture {
                onSelectProposal(proposal)
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
    .errorToast($viewModel.errorMessage)
  }
}

#Preview {
  HomeView(viewModel: .preview())
}
