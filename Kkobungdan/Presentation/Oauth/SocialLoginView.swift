//
//  SocialLoginView.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct SocialLoginView: View {
  @State private var viewModel: SocialLoginViewModel

  init(viewModel: SocialLoginViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    ScreenContainer {
      VStack(spacing: 0) {
        Gap.v(150)

        brandSection

        Gap.v(72)

        socialButtonsSection

        Spacer()

        bottomTermsSection
          .padding(.bottom, 23)
      }
    }
    .sheet(isPresented: $viewModel.isTermsSheetPresented) {
      TermsAgreementView(
        viewModel: TermsAgreementViewModel(),
        onBack: { viewModel.isTermsSheetPresented = false },
        onComplete: { viewModel.completeTermsAgreement() }
      )
    }
    .errorToast($viewModel.errorMessage)
  }

  private var brandSection: some View {
    VStack(spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 24)
          .fill(Color.gray500)
          .frame(width: 96, height: 96)

        // TODO: 브랜드 로고 추가
      }

      VStack(spacing: 8) {
        Text("브랜드명")
          .textStyle(.display)
          .foregroundColor(Color.gray900)
          .multilineTextAlignment(.center)

        Text("내용")
          .textStyle(.body4)
          .foregroundColor(Color.gray600)
          .multilineTextAlignment(.center)
      }
    }
    .frame(width: 120, height: 176)
  }

  private var socialButtonsSection: some View {
    VStack(spacing: 12) {
      // 카카오 로그인 버튼
      Button {
        Task { await viewModel.kakaoLogin() }
      } label: {
        HStack(spacing: 6) {
          Image("icon_kakao")
            .resizable()
            .frame(width: 24, height: 24)

          Text("카카오로 시작하기")
            .textStyle(.body1)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.kakaoBrand)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      .disabled(viewModel.isKakaoLoading)

      // 애플 로그인 버튼
      Button {
        Task { await viewModel.appleLogin() }
      } label: {
        HStack(spacing: 6) {
          Image("icon_apple")
            .resizable()
            .frame(width: 24, height: 24)

          Text("Apple로 시작하기")
            .textStyle(.body1)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
      .disabled(viewModel.isAppleLoading)
    }
    .padding(.horizontal, 4)
    .frame(maxWidth: .infinity)
  }

  private var bottomTermsSection: some View {
    VStack(spacing: 0) {
      HStack(spacing: 2) {
        Text("로그인하면 오더런의")
          .textStyle(.caption5)
          .foregroundColor(Color.gray500)
        Text("이용약관")
          .textStyle(.caption5)
          .foregroundColor(Color.gray500)
          .underline()
        Text("및")
          .textStyle(.caption5)
          .foregroundColor(Color.gray500)
      }
      HStack(spacing: 2) {
        Text("개인정보처리방침")
          .textStyle(.caption5)
          .foregroundColor(Color.gray500)
          .underline()
        Text("에 동의하게 됩니다")
          .textStyle(.caption5)
          .foregroundColor(Color.gray500)
      }
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  SocialLoginView(
    viewModel: SocialLoginViewModel(
      emailLoginUseCase: EmailLoginUseCase(oauthRepository: DIContainer.oauthRepository),
      appleLoginUseCase: AppleLoginUseCase(oauthRepository: DIContainer.oauthRepository),
      kakaoLoginUseCase: KakaoLoginUseCase(oauthRepository: DIContainer.oauthRepository)
    )
  )
}
