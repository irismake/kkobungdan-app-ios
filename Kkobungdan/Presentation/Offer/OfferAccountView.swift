//
//  OfferAccountView.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//
//  지원 흐름 1단계: 계좌 등록. (요청 상세 → 계좌 등록 → 첫 인사(OfferMessageView) → 지원 완료)
//  임무 수행비를 받을 계좌번호·은행을 등록한 뒤 첫 인사 단계로 넘어간다.
//

import SwiftUI

struct OfferAccountView: View {
  @State private var viewModel: OfferAccountViewModel
  var onBack: () -> Void = {}
  var onRegistered: () -> Void = {}

  @FocusState private var focus: Field?

  private enum Field: Hashable {
    case account
    case holder
  }

  init(
    viewModel: OfferAccountViewModel,
    onBack: @escaping () -> Void = {},
    onRegistered: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onRegistered = onRegistered
  }

  var body: some View {
    @Bindable var account = viewModel.account
    return VStack(spacing: 0) {
      header

      ScrollView {
        VStack(spacing: 24) {
          accountNumberField
          bankField
          accountHolderField
        }
        .padding(16)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      BottomActionBar(title: "다음", isEnabled: viewModel.canProceed) {
        Task {
          if await viewModel.registerAccount() {
            onRegistered()
          }
        }
      }
    }
    // 시트는 safeAreaInset(지원하기 버튼)보다 바깥의 overlay 라야 버튼 위로 스택된다.
    .overlay {
      if viewModel.account.isBankSheetPresented {
        BankSelectSheet(
          banks: viewModel.account.banks,
          onClose: { viewModel.account.dismissBankSheet() },
          onSelect: { viewModel.account.selectBank($0) }
        )
      }
    }
    .navigationBarBackButtonHidden(true)
    .task { await viewModel.account.loadAccount() }
    .errorToast($account.errorMessage)
  }

  // MARK: - Header

  private var header: some View {
    VStack(alignment: .leading, spacing: 12) {
      CloseHeader(title: "계좌 등록", onClose: onBack)

      Text("임무 수행비를 받을 계좌를 등록해 주세요")
        .textStyle(.body3)
        .foregroundColor(.gray600)
        .padding(.leading, 16)
    }
    .padding(.top, 8)
    .padding(.bottom, 32)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)
    }
  }

  // MARK: - Fields

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
            .foregroundColor(viewModel.account.selectedBank == nil ? .gray500 : .gray900)

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
  OfferAccountView(
    viewModel: AppRouteFactory.makeOfferAccountViewModel(proposalID: 1)
  )
}
