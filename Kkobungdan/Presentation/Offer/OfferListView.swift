//
//  OfferListView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct OfferListView: View {
  @State private var viewModel: OfferListViewModel
  var onBack: () -> Void = {}
  var onAccepted: () -> Void = {}
  var onSelectRunner: (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in }
  /// 지원자 카드의 '대화 보기' → 해당 지원자와의 채팅 상세.
  var onOpenChat: (Offer) -> Void = { _ in }

  @State private var isSelectModalPresented: Bool = false
  @State private var selectedRunner: Offer?

  init(
    viewModel: OfferListViewModel,
    onBack: @escaping () -> Void = {},
    onAccepted: @escaping () -> Void = {},
    onSelectRunner: @escaping (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in },
    onOpenChat: @escaping (Offer) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onAccepted = onAccepted
    self.onSelectRunner = onSelectRunner
    self.onOpenChat = onOpenChat
  }

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        AppBar(title: "지원 리스트", onBack: onBack)

        ScrollView {
          VStack(alignment: .leading, spacing: 12) {
            headerSection

            if viewModel.isLoading, viewModel.runners.isEmpty {
              ProgressView().padding(.top, 20)
                .frame(maxWidth: .infinity)
            } else {
              ForEach(viewModel.runners) { runner in
                runnerCard(runner)
              }
            }
          }
          .padding(.horizontal, Layout.screenHorizontalPadding)
          .padding(.vertical, 12)
        }
      }
      .background(Color.gray000)
      .task {
        await viewModel.load()
      }
      .refreshable {
        await viewModel.load()
      }

      if isSelectModalPresented, let selectedRunner {
        RunnerSelectModal(
          runnerName: selectedRunner.runnerName,
          onCancel: {
            isSelectModalPresented = false
            self.selectedRunner = nil
          },
          onConfirm: {
            Task {
              await viewModel.acceptOffer(offerID: selectedRunner.id)
              if viewModel.didAcceptOffer {
                isSelectModalPresented = false
                self.selectedRunner = nil
                onAccepted()
              }
            }
          }
        )
      }
    }
    .errorToast($viewModel.errorMessage)
  }

  private func runnerCard(_ runner: Offer) -> some View {
    VStack(spacing: 8) {
      RunnerCard(
        nickname: runner.runnerName,
        level: runner.runnerLevel,
        appliedAt: DisplayFormatter.appliedAtString(runner.createdAt),
        onOpenChat: {
          onOpenChat(runner)
        }
      )
    }
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(viewModel.proposal?.title ?? "")
        .textStyle(.body2)
        .kerning(-0.15)
        .foregroundColor(Color.gray600)

      HStack(spacing: 0) {
        Text("\(viewModel.runners.count)명")
          .textStyle(.heading3, weight: .bold)
          .foregroundColor(Color.indigo500)

        Text("이 웨이팅을 지원했습니다")
          .textStyle(.heading3)
          .foregroundColor(Color.gray700)
      }
    }
  }
}
