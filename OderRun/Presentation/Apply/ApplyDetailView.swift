//
//  ApplyDetailView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct ApplyDetailView: View {
  @State private var viewModel: ApplyDetailViewModel
  @State private var isMissionCompleted: Bool = false
  var onBack: () -> Void = {}

  init(
    viewModel: ApplyDetailViewModel,
    onBack: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
  }

  var body: some View {
    ZStack {
      contentView

      if isMissionCompleted {
        MissionCompleteModal(
          title: "진행 완료 처리하시겠습니까?",
          isApplicant: true,
          infoTitle: "취소 안내",
          infoContent: "완료 처리 후 취소가 불가능하며 문제 발생 시 고객센터 이메일로 문의 부탁드립니다.",
          onCancel: { isMissionCompleted = false },
          onConfirm: {
            Task {
              await viewModel.completeDelivery()
              isMissionCompleted = false
            }
          }
        )
      }
    }
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      AppBar(title: "지원 상세", onBack: onBack)

      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 12) {
            proposalCardSection

            if let errorMessage = viewModel.errorMessage {
              Text(errorMessage)
                .textStyle(.body3)
                .foregroundColor(Color.rose500)
                .padding(.horizontal, 16)
            }
          }
          .padding(.horizontal, Layout.screenHorizontalPadding)
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
  }

  @ViewBuilder
  private var bottomActionSection: some View {
    if viewModel.canCompleteDelivery {
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
