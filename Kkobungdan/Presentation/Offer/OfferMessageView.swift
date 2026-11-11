//
//  OfferMessageView.swift
//  Kkobungdan
//
//  지원 흐름 2단계: 첫 인사(지원 메시지) 작성 화면.
//  (요청 상세 → 계좌 등록 → 첫 인사 → 지원 완료)
//

import SwiftUI

struct OfferMessageView: View {
  @State private var viewModel: OfferMessageViewModel
  var onBack: () -> Void = {}
  var onApplied: (Int64) -> Void = { _ in }

  init(
    viewModel: OfferMessageViewModel,
    onBack: @escaping () -> Void = {},
    onApplied: @escaping (Int64) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onApplied = onApplied
  }

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "지원하기", onBack: onBack)
      Rectangle().fill(Color.gray200).frame(height: 1)

      ScrollView {
        VStack(alignment: .leading, spacing: 0) {
          intro
          proposalSummary
            .padding(.top, 24)
          messageField
            .padding(.top, 24)
          notice
            .padding(.top, 24)
        }
        .padding(16)
      }
      .scrollDismissesKeyboard(.interactively)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.gray000)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      BottomActionBar(title: "지원하기", isEnabled: viewModel.canOffer) {
        Task {
          if let offerID = await viewModel.offer() {
            onApplied(offerID)
          }
        }
      }
    }
    .navigationBarBackButtonHidden(true)
    .task { await viewModel.load() }
    .errorToast($viewModel.errorMessage)
  }

  // MARK: - Sections

  private var intro: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("첫 인사를 보내주세요")
        .textStyle(.heading7)
        .foregroundColor(.gray900)
        .padding(.top, 4)

      Text("가능한 시간과 궁금한 점을 알려주세요.\n지원하면 행님과의 채팅방이 열려요.")
        .textStyle(.body5)
        .foregroundColor(.gray500)
    }
  }

  @ViewBuilder
  private var proposalSummary: some View {
    if let proposal = viewModel.proposal {
      VStack(alignment: .leading, spacing: 6) {
        Text(proposal.title)
          .textStyle(.heading4)
          .kerning(0)
          .foregroundColor(.gray900)

        Text("\(DisplayFormatter.dateString(proposal.deadline)) · \(DisplayFormatter.timeString(proposal.deadline))")
          .textStyle(.caption7)
          .foregroundColor(.gray500)

        Text(DisplayFormatter.feeString(proposal.errandFee))
          .textStyle(.title4)
          .foregroundColor(.indigo500)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 10))
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .stroke(Color.gray200, lineWidth: 1)
      )
    }
  }

  private var messageField: some View {
    LabeledFieldContainer(label: "지원 메시지") {
      ContentTextField(
        placeholder: "안녕하세요! 요청하신 시간에 도착할 수 있어요. 정확한 만남 장소를 알려주실 수 있나요?",
        text: $viewModel.message,
        maxLength: OfferMessageViewModel.maxMessageLength
      )
    }
  }

  private var notice: some View {
    Text("지원만으로 매칭이 확정되지는 않아요. 채팅으로 조건을 확인한 뒤 행님이 지원자를 선택해요.")
      .textStyle(.caption2)
      .kerning(0)
      .foregroundColor(.gray500)
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Color.gray100)
      .clipShape(RoundedRectangle(cornerRadius: 10))
  }
}

#Preview {
  NavigationStack {
    OfferMessageView(viewModel: .preview())
  }
}
