//
//  AddProposalFeeView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/28/26.
//

import SwiftUI

struct AddProposalFeeView: View {
  private let draft: AddProposalDraft
  @State private var viewModel: AddProposalViewModel
  @State private var feeText: String

  @FocusState private var focus: Field?

  private enum Field: Hashable {
    case account
    case holder
  }

  let onBack: () -> Void
  let onCreated: (Proposal) -> Void

  init(
    draft: AddProposalDraft,
    viewModel: AddProposalViewModel,
    onBack: @escaping () -> Void = {},
    onCreated: @escaping (Proposal) -> Void = { _ in }
  ) {
    self.draft = draft
    _viewModel = State(initialValue: viewModel)
    _feeText = State(initialValue: draft.errandFee.map(String.init) ?? "")
    self.onBack = onBack
    self.onCreated = onCreated
  }

  /// 계좌 등록 또는 의뢰 생성이 진행 중인지.
  private var isBusy: Bool {
    viewModel.isSubmitting || viewModel.account.isRegistering
  }

  private var isSubmitEnabled: Bool {
    !feeText.isEmpty && Int(feeText) != nil
      && draft.deadline != nil && viewModel.canSubmit
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          feeField
          accountNumberField
          bankField
          accountHolderField

          if let errorMessage = viewModel.errorMessage ?? viewModel.account.errorMessage {
            Text(errorMessage)
              .textStyle(.body3)
              .foregroundColor(Color.rose500)
          }
        }
        .padding(16)
      }

      BottomActionBar(
        title: isBusy ? "등록 중..." : "등록하기",
        isEnabled: isSubmitEnabled
      ) {
        submit()
      }
    }
    .background(Color.gray000)
    // 시트는 BottomActionBar 위로 스택되도록 바깥 overlay 로 둔다.
    .overlay {
      if viewModel.account.isBankSheetPresented {
        BankSelectSheet(
          banks: viewModel.account.banks,
          onClose: { viewModel.account.dismissBankSheet() },
          onSelect: { viewModel.account.selectBank($0) }
        )
      }
    }
    .navigationBarHidden(true)
    .task { await viewModel.account.loadAccount() }
  }

  private func submit() {
    guard let fee = Int(feeText), let deadline = draft.deadline, !isBusy else {
      return
    }
    Task {
      // 계좌가 없으면 먼저 계좌를 등록한 뒤 의뢰를 생성한다.
      guard await viewModel.account.register() else {
        return
      }
      if let proposal = await viewModel.submit(
        title: draft.title,
        content: draft.content,
        deadline: deadline,
        errandFee: fee
      ) {
        onCreated(proposal)
      }
    }
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppBar(progress: (3, 3), onBack: onBack)

      VStack(alignment: .leading, spacing: 8) {
        Text("수행비 입력")
          .textStyle(.heading3)
          .foregroundColor(Color.gray900)
          .padding(.horizontal, 16)

        Text("꼬붕에게 전달할 수행비를 제시해 주세요")
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
    LabeledFieldContainer(label: "수행비") {
      FocusTextField(
        text: $feeText,
        placeholder: "금액을 작성해 주세요",
        keyboardType: .numberPad,
        autoFocus: true
      )
    }
  }

  private var accountNumberField: some View {
    @Bindable var account = viewModel.account
    return LabeledFieldContainer(label: "계좌번호") {
      FocusTextField(
        text: $account.accountNumber,
        placeholder: "환불받을 계좌번호를 입력해 주세요",
        keyboardType: .numberPad,
        focus: $focus,
        focusValue: .account
      )
      .disabled(viewModel.account.hasAccount)
    }
  }

  private var bankField: some View {
    LabeledFieldContainer(label: "은행") {
      Button {
        focus = nil
        viewModel.account.openBankSheet()
      } label: {
        HStack(spacing: 8) {
          Text(viewModel.account.selectedBank ?? "은행을 선택해 주세요")
            .textStyle(.inputBody1)
            .foregroundColor(viewModel.account.selectedBank == nil ? Color.gray500 : Color.gray900)

          Spacer(minLength: 0)

          Image("icon_arrow_down")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        }
        .textFieldBox(isActive: viewModel.account.isBankSheetPresented)
      }
      .buttonStyle(.plain)
      .disabled(viewModel.account.hasAccount)
    }
  }

  private var accountHolderField: some View {
    @Bindable var account = viewModel.account
    return LabeledFieldContainer(label: "예금주명") {
      FocusTextField(
        text: $account.accountHolder,
        placeholder: "환불받을 계좌의 예금주명을 입력해 주세요",
        focus: $focus,
        focusValue: .holder
      )
      .disabled(viewModel.account.hasAccount)
    }
  }
}

#Preview {
  AddProposalFeeView(
    draft: AddProposalDraft(title: "샘플", content: "내용", deadline: Date()),
    viewModel: AppRouteFactory.makeAddProposalViewModel()
  )
}
