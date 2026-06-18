//
//  AccountRegisterView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//
//  지원하기 → 지원 완료 사이에 들어가는 계좌 등록 화면.
//  임무 수행비를 받을 계좌번호·은행을 입력한 뒤 실제 offer 를 생성한다.
//

import SwiftUI

struct AccountRegisterView: View {
  @State private var viewModel: AccountRegisterViewModel
  var onBack: () -> Void = {}
  var onApplied: () -> Void = {}

  @FocusState private var focus: Field?

  private enum Field: Hashable {
    case account
  }

  init(
    viewModel: AccountRegisterViewModel,
    onBack: @escaping () -> Void = {},
    onApplied: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onApplied = onApplied
  }

  var body: some View {
    VStack(spacing: 0) {
      header

      ScrollView {
        VStack(spacing: 24) {
          accountNumberField
          bankField

          if let errorMessage = viewModel.errorMessage {
            Text(errorMessage)
              .textStyle(.body3)
              .foregroundColor(Color.rose500)
              .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
        .padding(16)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      BottomActionBar(title: "임무 지원하기", isEnabled: viewModel.canApply) {
        Task {
          if await viewModel.apply() {
            onApplied()
          }
        }
      }
    }
    // 시트는 safeAreaInset(지원하기 버튼)보다 바깥의 overlay 라야 버튼 위로 스택된다.
    .overlay {
      if viewModel.isBankSheetPresented {
        BankSelectSheet(
          banks: viewModel.banks,
          onClose: { viewModel.dismissBankSheet() },
          onSelect: { viewModel.selectBank($0) }
        )
      }
    }
    .navigationBarBackButtonHidden(true)
  }

  // MARK: - Header

  private var header: some View {
    VStack(alignment: .leading, spacing: 12) {
      CloseHeader(title: "계좌 등록", closePosition: .trailing, onClose: onBack)

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
    LabeledFieldContainer(label: "계좌번호") {
      FocusTextField(
        text: $viewModel.accountNumber,
        placeholder: "환불받을 계좌번호를 입력해 주세요",
        keyboardType: .numberPad,
        focus: $focus,
        focusValue: .account
      )
    }
  }

  private var bankField: some View {
    LabeledFieldContainer(label: "은행") {
      Button {
        focus = nil
        viewModel.openBankSheet()
      } label: {
        HStack(spacing: 8) {
          Text(viewModel.selectedBank ?? "은행을 선택해 주세요")
            .textStyle(.inputBody1)
            .foregroundColor(viewModel.selectedBank == nil ? .gray500 : .gray900)

          Spacer(minLength: 0)

          Image("icon_arrow_down")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
        }
        .textFieldBox(isActive: viewModel.isBankSheetPresented)
      }
      .buttonStyle(.plain)
    }
  }
}

#Preview {
  AccountRegisterView(
    viewModel: AccountRegisterViewModel(
      proposalID: 1,
      createOfferUseCase: CreateOfferUseCase(repository: DIContainer.offerRepository)
    )
  )
}
