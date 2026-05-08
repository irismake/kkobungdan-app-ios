//
//  MyProposalDetailView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct MyProposalDetailView: View {
  @State private var viewModel: MyProposalDetailViewModel
  var onBack: () -> Void = {}
  var onShowApplicants: () -> Void = {}
  var onAccepted: () -> Void = {}

  init(
    viewModel: MyProposalDetailViewModel,
    onBack: @escaping () -> Void = {},
    onShowApplicants: @escaping () -> Void = {},
    onAccepted: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onShowApplicants = onShowApplicants
    self.onAccepted = onAccepted
  }

  private var statusBadge: BadgeItem? {
    guard let status = viewModel.proposal?.status else {
      return nil
    }
    switch status {
    case .posted:
      return BadgeItem(text: "대기중", textColor: .blue500, bgColor: .blue000)
    case .offered:
      return BadgeItem(text: "지원 도착", textColor: .amber600, bgColor: .amber000)
    case .matched:
      return BadgeItem(text: "매칭 완료", textColor: .emerald500, bgColor: .emerald000)
    case .cancelled:
      return BadgeItem(text: "취소됨", textColor: .gray500, bgColor: .gray100)
    }
  }

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "내 요청 상세", onBack: onBack)

      VStack(spacing: 0) {
        ScrollView {
          ScreenContainer {
            VStack(spacing: 12) {
              proposalCardSection

              MissionStatusSection(viewModel: viewModel.missionViewModel)
            }
          }
          .padding(.vertical, 12)
        }

        Spacer()

        Text("고객센터 email@gmail")
          .textStyle(.body3)
          .foregroundColor(Color.gray700)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .padding(.bottom, 32)
      }
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }

      bottomActionSection
        .padding(.horizontal, Layout.screenHorizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 32)
    }
    .background(Color.gray000)
    .task {
      await viewModel.load()
    }
    .refreshable {
      await viewModel.load()
    }
    .onChange(of: viewModel.didCancel) { _, didCancel in
      if didCancel {
        onBack()
      }
    }
  }

  @ViewBuilder
  private var bottomActionSection: some View {
    switch viewModel.proposal?.status {
    case .matched:
      Button(action: onAccepted) {
        Text("만났어요!")
          .textStyle(.heading4)
          .foregroundColor(.white)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(Color.emerald500)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      .buttonStyle(.plain)
    case .cancelled:
      EmptyView()
    default:
      VStack(spacing: 8) {
        ConfirmButton(
          title: "지원 보기(\(viewModel.applicantCount))",
          isEnabled: viewModel.applicantCount > 0
        ) {
          onShowApplicants()
        }

        CancelButton(title: viewModel.isCancelling ? "취소 중..." : "요청 취소") {
          Task { await viewModel.cancelProposal() }
        }
      }
    }
  }

  @ViewBuilder
  private var proposalCardSection: some View {
    if let proposal = viewModel.proposal {
      ProposalCard(
        title: proposal.title,
        description: proposal.content,
        date: ProposalDisplay.dateString(proposal.deadline),
        time: ProposalDisplay.timeString(proposal.deadline),
        fee: ProposalDisplay.feeString(proposal.errandFee),
        badges: statusBadge.map { [$0] } ?? []
      )
    } else if viewModel.isLoading {
      ProgressView()
    } else if let errorMessage = viewModel.errorMessage {
      Text(errorMessage)
        .textStyle(.body3)
        .foregroundColor(Color.rose500)
    }
  }
}
