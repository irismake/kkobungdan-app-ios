//
//  ProposalDetailView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct ProposalDetailView: View {
  @State private var viewModel: ProposalDetailViewModel
  var onBack: () -> Void = {}
  var onOffer: () -> Void = {}
  var onMine: () -> Void = {}
  /// 내가 지원한 요청이면 내 지원 상세로 교체한다.
  var onMyOffer: (Int64) -> Void = { _ in }
  var onReport: () -> Void = {}

  init(
    viewModel: ProposalDetailViewModel,
    onBack: @escaping () -> Void = {},
    onOffer: @escaping () -> Void = {},
    onMine: @escaping () -> Void = {},
    onMyOffer: @escaping (Int64) -> Void = { _ in },
    onReport: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onOffer = onOffer
    self.onMine = onMine
    self.onMyOffer = onMyOffer
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
          title: "지원하기",
          // 불러오기 전·교체 직전(내 요청/내 지원)에는 누르지 못하게 막는다.
          isEnabled: viewModel.proposal != nil && !viewModel.isMine && viewModel.myOfferID == nil
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
      // 내 요청 → 내 요청 상세, 내 지원 있음 → 내 지원 상세, 둘 다 아니면 이 화면(지원하기)
      if viewModel.isMine {
        onMine()
      } else if let offerID = viewModel.myOfferID {
        onMyOffer(offerID)
      }
    }
    .errorToast($viewModel.errorMessage)
  }

  private var reportButton: some View {
    Button(action: onReport) {
      Text("신고하기")
        .textStyle(.button1)
        .foregroundColor(Color.rose800)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Color.gray100)
        .clipShape(RoundedRectangle(cornerRadius: 4))
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
        date: DisplayFormatter.dateString(proposal.deadline),
        time: DisplayFormatter.timeString(proposal.deadline),
        fee: DisplayFormatter.feeString(proposal.errandFee),
        badges: ActivityStatusBadge.badges(proposal: proposal)
      )

      reportButton
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
  }
}
