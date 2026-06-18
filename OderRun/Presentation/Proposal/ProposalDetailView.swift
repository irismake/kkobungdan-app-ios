//
//  ProposalDetailView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct ProposalDetailView: View {
  @State private var viewModel: ProposalDetailViewModel
  var onBack: () -> Void = {}
  var onApply: () -> Void = {}
  var onMine: () -> Void = {}

  init(
    viewModel: ProposalDetailViewModel,
    onBack: @escaping () -> Void = {},
    onApply: @escaping () -> Void = {},
    onMine: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onApply = onApply
    self.onMine = onMine
  }

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "요청 상세", onBack: onBack)

      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 12) {
            proposalCardSection
          }
          .padding(.horizontal, Layout.screenHorizontalPadding)
          .padding(.vertical, 12)
        }
      }
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }

      VStack(spacing: 0) {
        ConfirmButton(
          title: applyButtonTitle,
          isEnabled: !viewModel.hasApplied
        ) {
          // TODO: 계좌번호 여부에 따라 분기
          onApply()
        }
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 32)
    }
    .background(Color.gray000)
    .task {
      await viewModel.load()
      if viewModel.isMine {
        onMine()
      }
    }
  }

  private var applyButtonTitle: String {
    viewModel.hasApplied ? "지원 완료" : "지원하기"
  }

  @ViewBuilder
  private var proposalCardSection: some View {
    if let proposal = viewModel.proposal {
      OrdererInfoHeader(name: proposal.ordererName, level: proposal.ordererLevel)
        .padding(.leading, 16)

      ProposalCard(
        title: proposal.title,
        description: proposal.content,
        date: ProposalDisplay.dateString(proposal.deadline),
        time: ProposalDisplay.timeString(proposal.deadline),
        fee: ProposalDisplay.feeString(proposal.errandFee),
        badges: ProposalDisplay.badges(proposal: proposal)
      )
    } else if let errorMessage = viewModel.errorMessage {
      Text(errorMessage)
        .textStyle(.body3)
        .foregroundColor(Color.rose500)
        .padding(.horizontal, 16)
    }
  }
}
