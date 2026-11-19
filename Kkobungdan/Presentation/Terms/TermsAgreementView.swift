//
//  TermsAgreementView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct TermsAgreementView: View {
  @State private var viewModel: TermsAgreementViewModel
  @Environment(\.openURL) private var openURL
  var onBack: () -> Void
  var onComplete: (() -> Void)?

  init(
    viewModel: TermsAgreementViewModel,
    onBack: @escaping () -> Void,
    onComplete: (() -> Void)? = nil
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onComplete = onComplete
  }

  var body: some View {
    VStack(spacing: 8) {
      AppBar(title: "약관 동의", onBack: onBack)

      VStack(spacing: 24) {
        subtitleSection
        termsListSection
      }
      .padding(.horizontal, 24)
      
      Spacer()

      BottomActionBar(title: "동의하고 시작하기", isEnabled: viewModel.canProceed) {
        onComplete?()
      }
    }
    .navigationBarHidden(true)
  }

  // MARK: - Subtitle

  private var subtitleSection: some View {
    Text("서비스 이용을 위해 아래 약관에 동의해 주세요.")
      .textStyle(.body3)
      .kerning(-0.15)
      .foregroundColor(Color.gray500)
      .frame(maxWidth: .infinity, alignment: .leading)
  }

  // MARK: - Terms List

  private var termsListSection: some View {
    VStack(spacing: 16) {
      allAgreeRow

      VStack(spacing: 16) {
        Rectangle()
          .fill(Color.gray100)
          .frame(height: 1)
      }

      VStack(spacing: 12) {
        termRow(
          title: "이용약관",
          isRequired: true,
          isAgreed: viewModel.isTermsAgreed,
          onToggle: { viewModel.isTermsAgreed.toggle() },
          onView: { openURL(PolicyURL.termsOfService) }
        )

        termRow(
          title: "개인정보 처리방침",
          isRequired: true,
          isAgreed: viewModel.isPrivacyAgreed,
          onToggle: { viewModel.isPrivacyAgreed.toggle() },
          onView: { openURL(PolicyURL.privacyPolicy) }
        )
      }
    }
  }

  private var allAgreeRow: some View {
    Button {
      viewModel.toggleAll()
    } label: {
      HStack(spacing: 12) {
        checkboxIcon(isChecked: viewModel.isAllAgreed, size: 24)

        Text("전체 동의")
          .textStyle(.body1)
          .foregroundColor(Color.gray900)

        Spacer()
      }
      .padding(.horizontal, 16)
      .frame(height: 58)
      .background(Color.gray100)
      .clipShape(RoundedRectangle(cornerRadius: 14))
      .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray200, lineWidth: 1))
    }
    .buttonStyle(.plain)
  }

  private func termRow(
    title: String,
    isRequired: Bool,
    isAgreed: Bool,
    onToggle: @escaping () -> Void,
    onView: @escaping () -> Void
  ) -> some View {
    HStack(spacing: 12) {
      Button(action: onToggle) {
        checkboxIcon(isChecked: isAgreed, size: 20)
      }
      .buttonStyle(.plain)

      Text(title)
        .textStyle(.body1)
        .foregroundColor(Color.gray900)

      if isRequired {
        Badge(text: "필수")
      }

      Spacer()

      Button(action: onView) {
        Text("보기")
          .textStyle(.body2)
          .kerning(-0.14)
          .foregroundColor(Color.gray700)
          .underline()
      }
      .buttonStyle(.plain)
    }
    .padding(.horizontal, 16)
    .frame(height: 58)
    .background(Color.white)
    .clipShape(RoundedRectangle(cornerRadius: 14))
    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.gray200, lineWidth: 1))
  }

  // MARK: - Checkbox Icon

  private func checkboxIcon(isChecked: Bool, size: CGFloat = 20) -> some View {
    ZStack {
      Circle()
        .fill(isChecked ? Color.indigo500 : Color.white)
        .overlay(Circle().stroke(isChecked ? Color.clear : Color.gray300, lineWidth: 2))
        .frame(width: size, height: size)

      if isChecked {
        Image("icon_check")
          .renderingMode(.template)
          .resizable()
          .scaledToFit()
          .frame(width: 12, height: 12)
          .foregroundColor(.white)
      }
    }
  }
}

#Preview {
  TermsAgreementView(viewModel: TermsAgreementViewModel(), onBack: {})
}
