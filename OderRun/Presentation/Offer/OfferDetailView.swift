//
//  OfferDetailView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct OfferDetailView: View {
  @State private var viewModel: OfferDetailViewModel
  @State private var isMissionCompleted: Bool = false
  @State private var isCancelConfirmPresented: Bool = false
  var onBack: () -> Void = {}

  init(
    viewModel: OfferDetailViewModel,
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
          title: "임무 완료 처리하시겠습니까?",
          isRunner: true,
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
        .padding(.bottom, 20)
    }
    .background(Color.gray000)
    .task {
      await viewModel.load()
    }
    .onChange(of: viewModel.didCancel) { _, didCancel in
      if didCancel {
        onBack()
      }
    }
    .alert("지원을 취소할까요?", isPresented: $isCancelConfirmPresented) {
      Button("취소", role: .cancel) {}
      Button("지원 취소", role: .destructive) {
        Task { await viewModel.cancelOffer() }
      }
    } message: {
      Text("지원을 취소하면 되돌릴 수 없어요.")
    }
  }

  @ViewBuilder
  private var bottomActionSection: some View {
    switch viewModel.offer?.status {
    case .accepted:
      VStack(spacing: 8) {
        MissionCompleteButton { isMissionCompleted = true }

        OutlineButton(title: "임무 중단") {
          // TODO: 분쟁 기능 추가
        }
      }

    case .runnerCompleted:
      VStack(spacing: 8) {
        Text("행님의 확인을 기다리는중...")
          .textStyle(.heading4)
          .foregroundColor(.gray400)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .frame(height: 56)
          .background(Color.gray200)
          .clipShape(RoundedRectangle(cornerRadius: 12))

        OutlineButton(title: "임무 중단") {
          // TODO: 분쟁 기능 추가
        }
      }

    case .waiting:
      OutlineButton(title: viewModel.isCancelling ? "취소 중..." : "지원 취소") {
        isCancelConfirmPresented = true
      }

    default:
      EmptyView()
    }
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
    } else if let errorMessage = viewModel.errorMessage {
      Text(errorMessage)
        .textStyle(.body3)
        .foregroundColor(Color.rose500)
        .padding(.horizontal, 16)
    }
  }
}
