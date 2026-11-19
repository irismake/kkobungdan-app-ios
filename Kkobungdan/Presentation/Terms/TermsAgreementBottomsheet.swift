//
//  TermsAgreementBottomsheet.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 회원가입 마지막에 띄우는 약관 동의 바텀시트.
/// 약관 항목 구성은 TermsAgreementView 와 동일하되, 시트 형태로만 제공한다.
struct TermsAgreementBottomsheet: View {
  let viewModel: TermsAgreementViewModel
  /// 동의 없이 닫기(dim 탭).
  let onClose: () -> Void
  /// "확인" 으로 동의 완료.
  let onConfirm: () -> Void

  @Environment(\.openURL) private var openURL
  @State private var isShown = false

  var body: some View {
    ZStack(alignment: .bottom) {
      Color.black.opacity(isShown ? 0.5 : 0)
        .ignoresSafeArea()
        .onTapGesture { close(onClose) }

      if isShown {
        sheet
          .transition(.move(edge: .bottom))
      }
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.25)) { isShown = true }
    }
  }

  private var sheet: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.gray400)
        .frame(width: 40, height: 4)
        .padding(.top, 8)
        .padding(.bottom, 16)

      VStack(alignment: .leading, spacing: 12) {
        Text("이용을 위해 동의가 필요해요")
          .textStyle(.heading4)
          .kerning(-0.3125)
          .foregroundColor(.gray900)
          .frame(maxWidth: .infinity, alignment: .leading)

        VStack(spacing: 16) {
          allAgreeRow

          Rectangle()
            .fill(Color.gray100)
            .frame(height: 1)

          VStack(spacing: 12) {
            termRow(
              title: "이용약관",
              isAgreed: viewModel.isTermsAgreed,
              onToggle: { viewModel.isTermsAgreed.toggle() },
              onView: { openURL(PolicyURL.termsOfService) }
            )

            termRow(
              title: "개인정보 처리방침",
              isAgreed: viewModel.isPrivacyAgreed,
              onToggle: { viewModel.isPrivacyAgreed.toggle() },
              onView: { openURL(PolicyURL.privacyPolicy) }
            )
          }
          .padding(.bottom, 8)
        }
      }
      .padding(.horizontal, 24)
      .padding(.vertical, 8)

      BottomActionBar(title: "확인", isEnabled: viewModel.canProceed) {
        close(onConfirm)
      }
    }
    .frame(maxWidth: .infinity)
    .background(
      UnevenRoundedRectangle(topLeadingRadius: 12, topTrailingRadius: 12)
        .fill(Color.white)
        .ignoresSafeArea(edges: .bottom)
    )
  }

  // MARK: - Rows

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

      Badge(text: "필수")

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

  private func close(_ completion: @escaping () -> Void) {
    withAnimation(.easeIn(duration: 0.2)) {
      isShown = false
    } completion: {
      completion()
    }
  }
}

#Preview {
  ZStack {
    Color.gray000.ignoresSafeArea()
    TermsAgreementBottomsheet(
      viewModel: TermsAgreementViewModel(),
      onClose: {},
      onConfirm: {}
    )
  }
}
