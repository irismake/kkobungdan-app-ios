//
//  MyProposalDetailView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct MyProposalDetailView: View {
  @Environment(\.openURL) private var openURL
  @State private var viewModel: MyProposalDetailViewModel
  @State private var isMissionCompleted: Bool = false
  /// 계좌번호 복사 안내 토스트 메시지.
  @State private var toastMessage: String?
  var onBack: () -> Void = {}
  var onShowRunners: () -> Void = {}
  var onAccepted: () -> Void = {}
  var onAbort: () -> Void = {}

  init(
    viewModel: MyProposalDetailViewModel,
    onBack: @escaping () -> Void = {},
    onShowRunners: @escaping () -> Void = {},
    onAccepted: @escaping () -> Void = {},
    onAbort: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onShowRunners = onShowRunners
    self.onAccepted = onAccepted
    self.onAbort = onAbort
  }

  private var statusBadges: [BadgeItem] {
    guard let proposal = viewModel.proposal else {
      return []
    }
    return ActivityStatusBadge.badges(proposal: proposal)
  }

  var body: some View {
    ZStack {
      contentView

      if isMissionCompleted {
        MissionCompleteModal(
          title: "진행 완료 처리하시겠습니까?",
          isRunner: false,
          infoTitle: "취소 안내",
          infoContent: "완료 처리 후 취소가 불가능하며 문제 발생 시 고객센터 이메일로 문의 부탁드립니다.",
          onCancel: { isMissionCompleted = false },
          onConfirm: {
            Task {
              await viewModel.confirmReceived()
              isMissionCompleted = false
            }
          }
        )
      }
    }
    .errorToast($viewModel.errorMessage)
    .errorToast($toastMessage)
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      AppBar(title: "내 요청 상세", onBack: onBack)

      VStack(spacing: 0) {
        if viewModel.proposal == nil, viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
          ScrollView {
            ScreenContainer {
              VStack(spacing: 12) {
                proposalCardSection

                if viewModel.proposal?.status == .holding {
                  AccountInfoCard(
                    bankName: DepositAccount.bankName,
                    accountNumber: DepositAccount.accountNumber,
                    onCopy: {
                      toastMessage = "\(DepositAccount.holderName) 계좌번호가 복사되었습니다."
                    }
                  )
                }

                if let matched = viewModel.matchedOffer {
                  MatchedRunnerSection(
                    nickname: matched.runnerName,
                    level: matched.runnerLevel,
                    appliedAt: DisplayFormatter.appliedAtString(matched.createdAt)
                  )
                }

                if let openChatURL = viewModel.openChatURL {
                  OpenChatModal(urlString: openChatURL)
                }
              }
            }
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
    .refreshable {
      await viewModel.load()
    }
    .onChange(of: viewModel.didCancel) { _, didCancel in
      if didCancel {
        onBack()
      }
    }
  }

  /// 하단 액션 버튼이 있는지 여부. 없으면 구분선도 숨긴다.
  private var hasBottomAction: Bool {
    switch viewModel.proposal?.status {
    case .disputed:
      return viewModel.isDisputedByCounterparty
    case .allCompleted, .cancelled, .resolved:
      return false
    default:
      return true
    }
  }

  @ViewBuilder
  private var bottomActionSection: some View {
    switch viewModel.proposal?.status {
    case .matched:
      VStack(spacing: 8) {
        MissionCompleteButton { isMissionCompleted = true }

        OutlineButton(title: "임무 중단") {
          onAbort()
        }
      }
    case .orderCompleted:
      VStack(spacing: 8) {
        Text("꼬붕의 확인을 기다리는중...")
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
    case .disputed:
      // 내가 중단을 신청한 경우엔 버튼 없음. 중단을 당한 경우에만 문의하기 노출.
      if viewModel.isDisputedByCounterparty {
        VStack(spacing: 8) {
          Text("꼬붕이 임무를 중단했습니다.")
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
    case .allCompleted, .cancelled, .resolved:
      EmptyView()
    default:
      VStack(spacing: 8) {
        if viewModel.runnerCount > 0 {
          FillButton(title: "꼬붕 지원자(\(viewModel.runnerCount))") {
            onShowRunners()
          }
        } else {
          Text("아직 지원한 꼬붕이 없습니다")
            .textStyle(.heading4)
            .foregroundColor(.gray400)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.gray200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }

        OutlineButton(title: viewModel.isCancelling ? "취소 중..." : "요청 취소") {
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
        date: DisplayFormatter.dateString(proposal.deadline),
        time: DisplayFormatter.timeString(proposal.deadline),
        fee: DisplayFormatter.feeString(proposal.errandFee),
        badges: statusBadges
      )
    }
  }
}
