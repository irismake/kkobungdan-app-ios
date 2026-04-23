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

  init(
    viewModel: ProposalDetailViewModel,
    onBack: @escaping () -> Void = {},
    onApply: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onApply = onApply
  }

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "요청 상세", onBack: onBack)

      VStack(spacing: 0) {
        ScrollView {
          VStack(alignment: .leading, spacing: 12) {
            applicantProfileSection
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
        ConfirmButton(title: viewModel.isApplying ? "지원 중..." : "지원하기") {
          Task {
            await viewModel.apply()
            if viewModel.didApply {
              onApply()
            }
          }
        }
      }
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
  private var applicantProfileSection: some View {
    if let profile = viewModel.ordererProfile {
      applicantProfile(nickname: profile.nickname, level: profile.level, grade: profile.grade)
    } else if viewModel.isLoading {
      ProgressView().padding(.horizontal, 16)
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
        fee: ProposalDisplay.feeString(proposal.errandFee)
      )
    } else if let errorMessage = viewModel.errorMessage {
      Text(errorMessage)
        .textStyle(.body3)
        .foregroundColor(Color.rose500)
        .padding(.horizontal, 16)
    }
  }

  private func applicantProfile(nickname: String, level: Int, grade: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(nickname)
        .textStyle(.title1)
        .foregroundColor(.black)

      Text("웨이팅 레벨")
        .textStyle(.caption2)
        .foregroundColor(Color.gray500)

      HStack(spacing: 6) {
        Image("icon_users")
          .renderingMode(.template)
          .resizable()
          .frame(width: 16, height: 16)
          .foregroundColor(Color.amber500)

        HStack(spacing: 4) {
          HStack(spacing: 1) {
            Text("Lv \(level)")
            Text(":")
          }
          Text(grade)
        }
        .textStyle(.body2)
        .kerning(-0.15)
        .foregroundColor(Color.gray900)
      }
    }
    .padding(.horizontal, 16)
  }
}
