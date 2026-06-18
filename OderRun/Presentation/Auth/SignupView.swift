//
//  SignupView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 본인인증 플로우. 하나의 화면에서 입력을 마칠 때마다 다음 필드가 위에서부터 하나씩 나타난다.
struct SignupView: View {
  let onClose: () -> Void
  /// 약관 동의까지 마쳐 인증번호 단계로 넘어갈 때. (이름·숫자만 추린 휴대폰 번호·통신사 전달)
  let onComplete: (_ name: String, _ phone: String, _ carrier: String) -> Void

  @State private var viewModel = SignupViewModel()

  @FocusState private var focus: SignupViewModel.Focus?

  var body: some View {
    VStack(spacing: 0) {
      CloseHeader(title: viewModel.title, onClose: onClose)
        .padding(.top, 8)
        .padding(.bottom, 32)

      ScrollView {
        VStack(spacing: 32) {
          fields
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
      }
      .scrollBounceBehavior(.basedOnSize)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.white)
    .safeAreaInset(edge: .bottom, spacing: 0) {
      if showsBottomBar {
        BottomActionBar(title: "다음", isEnabled: viewModel.canProceed) {
          viewModel.goNext()
        }
      }
    }
    // 시트는 safeAreaInset(다음 버튼)보다 바깥의 overlay 라야 버튼 위로 스택된다.
    .overlay {
      if viewModel.isCarrierSheetPresented {
        CarrierSelectSheet(
          carriers: viewModel.carriers,
          onClose: { viewModel.dismissCarrierSheet() },
          onSelect: { viewModel.selectCarrier($0) }
        )
      }
    }
    .overlay {
      if viewModel.isTermsSheetPresented {
        TermsAgreementBottomsheet(
          viewModel: viewModel.termsViewModel,
          onClose: { viewModel.dismissTermsSheet() },
          onConfirm: {
            viewModel.completeTermsAgreement()
            onComplete(
              viewModel.name,
              viewModel.phoneNumber.filter(\.isNumber),
              viewModel.carrier ?? ""
            )
          }
        )
      }
    }
    .navigationBarBackButtonHidden(true)
    .toolbar(.hidden, for: .navigationBar)
    .onAppear { focus = viewModel.focus }
    .onChange(of: viewModel.focus) { _, new in
      // carrier 는 키보드가 없으므로 nil(키보드 내림)로 매핑한다. 시트 노출은 isCarrierSheetPresented 가 담당.
      let mapped = new.flatMap { $0.keyboardField }
      if focus != mapped {
        focus = mapped
      }
    }
    .onChange(of: focus) { _, new in
      if let new, viewModel.focus != new {
        viewModel.focus = new
      }
    }
  }

  /// 생년월일 → 이름 → 통신사 → 휴대폰 순(위에서 아래). 단계가 진행될수록 위에 필드가 하나씩 추가된다.
  /// 모든 필드는 항상 편집 가능 — 생년월일 단계에서도 아래의 휴대폰 번호를 다시 수정할 수 있다.
  @ViewBuilder
  private var fields: some View {
    if viewModel.step >= .birthDate {
      BirthDateField(
        birthDate: $viewModel.birthDate,
        focus: $focus,
        onChange: viewModel.formatBirthDate
      )
      .transition(.opacity.combined(with: .move(edge: .top)))
    }

    if viewModel.step >= .name {
      NameField(
        name: $viewModel.name,
        focus: $focus
      )
      .transition(.opacity.combined(with: .move(edge: .top)))
    }

    if viewModel.step >= .carrier {
      CarrierField(
        carrier: viewModel.carrier,
        isActive: viewModel.isCarrierSheetPresented,
        onTap: { viewModel.openCarrierSheet() }
      )
      .transition(.opacity.combined(with: .move(edge: .top)))
    }

    PhoneNumberField(
      phoneNumber: $viewModel.phoneNumber,
      focus: $focus,
      onChange: viewModel.fommatPhoneNumber
    )
  }

  /// 이름·생년월일 step은 하단 버튼으로 진행한다. (휴대폰은 자동, 통신사는 시트 선택으로 진행)
  private var showsBottomBar: Bool {
    viewModel.step == .name || viewModel.step == .birthDate
  }
}

#Preview {
  SignupView(onClose: {}, onComplete: { _, _, _ in })
}
