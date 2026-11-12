//
//  OfferDetailView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct OfferDetailView: View {
  @Environment(\.openURL) private var openURL
  @State private var viewModel: OfferDetailViewModel
  @State private var isMissionCompleted: Bool = false
  @State private var isCancelConfirmPresented: Bool = false
  var onBack: () -> Void = {}
  var onAbort: () -> Void = {}
  /// 관련 대화 → 채팅 화면. nil 이면 관련 대화 섹션을 숨긴다. (내 지원 상세에서만 전달)
  var onOpenChat: (() -> Void)?

  init(
    viewModel: OfferDetailViewModel,
    onBack: @escaping () -> Void = {},
    onAbort: @escaping () -> Void = {},
    onOpenChat: (() -> Void)? = nil
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onAbort = onAbort
    self.onOpenChat = onOpenChat
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

            // 관련 대화는 항상 맨 아래
            relatedChatSection
          }
          .padding(.horizontal, Layout.screenHorizontalPadding)
          .padding(.vertical, 12)
        }

        Spacer()

        Text("고객센터 \(SupportContact.email)")
          .textStyle(.body3)
          .foregroundColor(Color.gray700)
          .multilineTextAlignment(.center)
          .frame(maxWidth: .infinity)
          .padding(.bottom, 32)
      }
      .frame(maxHeight: .infinity)
      .overlay(alignment: .bottom) {
        if hasBottomAction {
          Rectangle()
            .fill(Color.gray200)
            .frame(height: 1)
        }
      }

      if hasBottomAction {
        bottomActionSection
          .padding(.horizontal, Layout.screenHorizontalPadding)
          .padding(.top, 16)
          .padding(.bottom, 20)
      }
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
    .errorToast($viewModel.errorMessage)
  }

  /// 하단 액션 버튼이 있는지 여부. 없으면 구분선도 숨긴다.
  private var hasBottomAction: Bool {
    switch viewModel.offer?.status {
    case .accepted, .runnerCompleted, .waiting:
      return true
    case .disputed:
      return viewModel.isDisputedByCounterparty
    default:
      return false
    }
  }

  @ViewBuilder
  private var bottomActionSection: some View {
    switch viewModel.offer?.status {
    case .accepted:
      VStack(spacing: 8) {
        MissionCompleteButton { isMissionCompleted = true }

        OutlineButton(title: "임무 중단") {
          onAbort()
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
          onAbort()
        }
      }

    case .waiting:
      OutlineButton(title: viewModel.isCancelling ? "취소 중..." : "지원 취소") {
        isCancelConfirmPresented = true
      }

    case .disputed:
      // 내가 중단을 신청한 경우엔 버튼 없음. 중단을 당한 경우에만 문의하기 노출.
      if viewModel.isDisputedByCounterparty {
        VStack(spacing: 8) {
          Text("행님이 임무를 중단했습니다.")
            .textStyle(.heading4)
            .foregroundColor(.gray400)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.gray200)
            .clipShape(RoundedRectangle(cornerRadius: 12))

          OutlineButton(title: "문의하기") {
            if let url = SupportContact.mailtoURL {
              openURL(url)
            }
          }
        }
      } else {
        EmptyView()
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
        date: DisplayFormatter.dateString(proposal.deadline),
        time: DisplayFormatter.timeString(proposal.deadline),
        fee: DisplayFormatter.feeString(proposal.errandFee),
        badges: ActivityStatusBadge.badges(proposal: proposal)
      )
    }
  }

  /// 내 지원 상세에서만(onOpenChat 전달 시) 노출, 화면 맨 아래.
  @ViewBuilder
  private var relatedChatSection: some View {
    if let proposal = viewModel.proposal, let onOpenChat,
       let status = ActivityStatusBadge.badges(proposal: proposal).first {
      // 상태 문구는 요청 카드 배지와 같게 맞춘다.
      ChatCard(items: [
        ChatCardItem(
          id: "\(proposal.id)",
          name: proposal.ordererName,
          statusText: status.text,
          onOpenChat: onOpenChat
        )
      ])
      .padding(.top, 4) // 위 섹션과 간격 16 (VStack spacing 12 + 4)
    }
  }
}
