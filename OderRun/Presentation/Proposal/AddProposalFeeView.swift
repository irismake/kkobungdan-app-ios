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
  @State private var accountNumber: String = ""
  @State private var selectedBank: String?
  @State private var isBankSheetPresented: Bool = false

  @FocusState private var focus: Field?

  private enum Field: Hashable {
    case account
  }

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
    !feeText.isEmpty && Int(feeText) != nil
      && !accountNumber.isEmpty && selectedBank != nil
      && draft.deadline != nil && !viewModel.isSubmitting
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          feeField
          accountNumberField
          bankField

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
    // 시트는 BottomActionBar 위로 스택되도록 바깥 overlay 로 둔다.
    .overlay {
      if isBankSheetPresented {
        BankSelectSheet(
          banks: BankSelectSheet.banks,
          onClose: { isBankSheetPresented = false },
          onSelect: { selectBank($0) }
        )
      }
    }
    .navigationBarHidden(true)
  }

  private func selectBank(_ bank: String) {
    selectedBank = bank
    isBankSheetPresented = false
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

  private var accountNumberField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("계좌번호")
        .textStyle(.body2)
        .foregroundColor(Color.gray800)

      SignupTextField(
        text: $accountNumber,
        placeholder: "환불받을 계좌번호를 입력해 주세요",
        keyboardType: .numberPad,
        focus: $focus,
        focusValue: .account
      )
    }
  }

  private var bankField: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("은행")
        .textStyle(.body2)
        .foregroundColor(Color.gray800)

      Button {
        focus = nil
        isBankSheetPresented = true
      } label: {
        HStack(spacing: 8) {
          Text(selectedBank ?? "은행을 선택해 주세요")
            .textStyle(.inputBody1)
            .foregroundColor(selectedBank == nil ? Color.gray500 : Color.gray900)

          Spacer(minLength: 0)

          Image("icon_arrow_down")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        }
        .signupFieldBox(isActive: isBankSheetPresented)
      }
      .buttonStyle(.plain)
    }
  }
}

#Preview {
  AddProposalFeeView(
    draft: AddProposalDraft(title: "샘플", content: "내용", deadline: Date()),
    viewModel: AppRouteFactory.makeAddProposalViewModel()
  )
}
