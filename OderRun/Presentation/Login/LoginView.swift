//
//  LoginView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct LoginView: View {
  @State private var viewModel: LoginViewModel

  init(viewModel: LoginViewModel) {
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
          .font(.custom("Pretendard-Bold", size: 30))
          .kerning(0.396)
          .appLineHeight(36, fontName: "Pretendard-Bold", fontSize: 30)
          .foregroundColor(Color.gray900)
          .multilineTextAlignment(.center)

        Text("내용")
          .font(.custom("Inter-Regular", size: 16))
          .kerning(-0.312)
          .appLineHeight(24, fontName: "Inter-Regular", fontSize: 16)
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
        // TODO: 카카오 로그인 액션
      } label: {
        HStack(spacing: 6) {
          Image("icon_kakao")
            .resizable()
            .frame(width: 24, height: 24)

          Text("카카오로 시작하기")
            .font(.custom("Pretendard-Medium", size: 16))
            .kerning(-0.3)
            .appLineHeight(24, fontName: "Pretendard-Medium", fontSize: 16)
            .foregroundColor(.black)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.kakaoBrand)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }

      // 애플 로그인 버튼
      Button {
        // TODO: 애플 로그인 액션
      } label: {
        HStack(spacing: 6) {
          Image("icon_apple")
            .resizable()
            .frame(width: 24, height: 24)

          Text("Apple로 시작하기")
            .font(.custom("Pretendard-Medium", size: 16))
            .kerning(-0.3)
            .appLineHeight(24, fontName: "Pretendard-Medium", fontSize: 16)
            .foregroundColor(.white)
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
    .padding(.horizontal, 4)
    .frame(maxWidth: .infinity)
  }

  private var bottomTermsSection: some View {
    VStack(spacing: 0) {
      HStack(spacing: 2) {
        Text("로그인하면 오더런의")
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(0)
          .appLineHeight(16, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray500)
        Text("이용약관")
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(0)
          .appLineHeight(16, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray500)
          .underline()
        Text("및")
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(0)
          .appLineHeight(16, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray500)
      }
      HStack(spacing: 2) {
        Text("개인정보처리방침")
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(0)
          .appLineHeight(16, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray500)
          .underline()
        Text("에 동의하게 됩니다")
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(0)
          .appLineHeight(16, fontName: "Pretendard-Regular", fontSize: 12)
          .foregroundColor(Color.gray500)
      }
    }
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  LoginView(
    viewModel: LoginViewModel(
      loginUseCase: LoginUseCase(authRepository: DIContainer.makeAuthRepository())
    )
  )
}
