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
  var onOffer: () -> Void = {}
  var onMine: () -> Void = {}
  var onReport: () -> Void = {}

  init(
    viewModel: ProposalDetailViewModel,
    onBack: @escaping () -> Void = {},
    onOffer: @escaping () -> Void = {},
    onMine: @escaping () -> Void = {},
    onReport: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onOffer = onOffer
    self.onMine = onMine
    self.onReport = onReport
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
        FillButton(
          title: offerButtonTitle,
          isEnabled: !viewModel.hasApplied
        ) {
          onOffer()
        }
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 20)
    }
    .background(Color.gray000)
    .task {
      await viewModel.load()
      if viewModel.isMine {
        onMine()
      }
    }
  }

  private var offerButtonTitle: String {
    viewModel.hasApplied ? "지원 완료" : "지원하기"
  }

  private var reportButton: some View {
    Button(action: onReport) {
      Text("신고하기")
        .textStyle(.caption1)
        .foregroundColor(Color.gray500)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    .buttonStyle(.plain)
  }

  @ViewBuilder
  private var proposalCardSection: some View {
    if let proposal = viewModel.proposal {
      UserInfoHeader(name: proposal.ordererName, level: proposal.ordererLevel)
        .padding(.leading, 16)

      ProposalCard(
        title: proposal.title,
        description: proposal.content,
        date: ProposalFormatter.dateString(proposal.deadline),
        time: ProposalFormatter.timeString(proposal.deadline),
        fee: ProposalFormatter.feeString(proposal.errandFee),
        badges: ActivityStatusBadge.badges(proposal: proposal)
      )

      reportButton
        .frame(maxWidth: .infinity, alignment: .trailing)
    } else if let errorMessage = viewModel.errorMessage {
      Text(errorMessage)
        .textStyle(.body3)
        .foregroundColor(Color.rose500)
        .padding(.horizontal, 16)
    }
  }
}
