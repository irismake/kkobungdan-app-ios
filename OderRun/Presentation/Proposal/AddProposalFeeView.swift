//
//  AddProposalFeeView.swift
//  OderRun
//
//  Created by 김가희 on 3/28/26.
//

import SwiftUI

struct AddProposalFeeView: View {
  private let draft: AddProposalDraft
  @State private var viewModel: AddProposalViewModel
  @State private var feeText: String

  let onBack: () -> Void
  let onCreated: (ProposalDetail) -> Void

  init(
    draft: AddProposalDraft,
    viewModel: AddProposalViewModel,
    onBack: @escaping () -> Void = {},
    onCreated: @escaping (ProposalDetail) -> Void = { _ in }
  ) {
    self.draft = draft
    _viewModel = State(initialValue: viewModel)
    _feeText = State(initialValue: draft.errandFee.map(String.init) ?? "")
    self.onBack = onBack
    self.onCreated = onCreated
  }

  private var isSubmitEnabled: Bool {
    !feeText.isEmpty && Int(feeText) != nil && draft.deadline != nil && !viewModel.isSubmitting
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          feeField

          AccountInfoCard(
            bankName: "토스뱅크",
            accountNumber: "1234-56-24687"
          )

          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
              .textStyle(.body3)
              .foregroundColor(Color.rose500)
          }
        }
        .padding(16)
      }

      BottomActionBar(
        title: viewModel.isSubmitting ? "등록 중..." : "등록하기",
        isEnabled: isSubmitEnabled
      ) {
        submit()
      }
    }
    .background(Color.gray000)
    .navigationBarHidden(true)
  }

  private func submit() {
    guard let fee = Int(feeText), let deadline = draft.deadline else {
      return
    }
    Task {
      if let detail = await viewModel.submit(
        title: draft.title,
        content: draft.content,
        deadline: deadline,
        errandFee: fee
      ) {
        onCreated(detail)
      }
    }
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppBar(isProgress: true, onBack: onBack)

      VStack(alignment: .leading, spacing: 8) {
        Text("웨이팅비 입력")
          .textStyle(.heading3)
          .foregroundColor(Color.gray900)
          .padding(.horizontal, 16)

        Text("원하는 웨이팅비를 제시해 주세요")
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 32)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)
    }
  }

  private var feeField: some View {
    TitleTextField(
      title: "웨이팅비",
      placeholder: "금액을 작성해 주세요",
      text: $feeText,
      autoFocus: true
    )
  }
}

#Preview {
  AddProposalFeeView(
    draft: AddProposalDraft(title: "샘플", content: "내용", deadline: Date()),
    viewModel: AppRouteFactory.makeAddProposalViewModel()
  )
}
