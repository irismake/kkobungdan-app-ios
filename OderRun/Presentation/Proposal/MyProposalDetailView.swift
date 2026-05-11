//
//  MyProposalDetailView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct MyProposalDetailView: View {
  @State private var viewModel: MyProposalDetailViewModel
  @State private var isMissionCompleted: Bool = false
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

  private var statusBadges: [BadgeItem] {
    guard let proposal = viewModel.proposal else {
      return []
    }
    return ProposalDisplay.badges(
      proposal: proposal,
      mission: viewModel.missionViewModel.mission
    )
  }

  var body: some View {
    ZStack {
      contentView

      if isMissionCompleted {
        MissionCompleteModal(
          title: "진행 완료 처리하시겠습니까?",
          isApplicant: false,
          infoTitle: "취소 안내",
          infoContent: "완료 처리 후 취소가 불가능하며 문제 발생 시 고객센터 이메일로 문의 부탁드립니다.",
          onCancel: { isMissionCompleted = false },
          onConfirm: {
            Task {
              await viewModel.missionViewModel.performAction(.confirmReceived)
              isMissionCompleted = false
            }
          }
        )
      }
    }
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      AppBar(title: "내 요청 상세", onBack: onBack)

      VStack(spacing: 0) {
        ScrollView {
          ScreenContainer {
            VStack(spacing: 12) {
              proposalCardSection

              if viewModel.missionViewModel.mission != nil,
                 let profile = viewModel.matchedRunnerProfile,
                 let matchedOffer = viewModel.matchedOffer
              {
                MatchedRunnerSection(
                  nickname: profile.nickname,
                  level: profile.level,
                  grade: profile.grade,
                  appliedAt: ProposalDisplay.appliedAtString(matchedOffer.createdAt)
                )
              }
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
      Button(action: { isMissionCompleted = true }) {
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
        badges: statusBadges
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
