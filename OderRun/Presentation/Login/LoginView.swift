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
    ZStack {
      Color.white
        .ignoresSafeArea()

      VStack(spacing: 0) {
        Spacer()
          .frame(height: 120) // 상단 여백 (상태바 + 디자인 상단 공간)

        brandSection

        Spacer()

        socialButtonsSection
          .padding(.bottom, 12)

        bottomTermsSection
          .padding(.bottom, 24)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .padding(.horizontal, 24)
    }
  }

  private var brandSection: some View {
    VStack(spacing: 12) {
      ZStack {
        RoundedRectangle(cornerRadius: 24)
          .fill(Color(UIColor.gray600)) // #7D889E
          .frame(width: 96, height: 96)

        Image(systemName: "figure.run")
          .font(.system(size: 40, weight: .bold))
          .foregroundStyle(Color.white)
      }

      VStack(spacing: 8) {
        Text("브랜드명")
          .font(.system(size: 30, weight: .bold))
          .foregroundStyle(Color(UIColor.gray950)) // #0F141D

        Text("내용")
          .font(.system(size: 16))
          .foregroundStyle(Color(UIColor.gray700)) // #5B6579
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
          Image(systemName: "message.fill")
            .font(.system(size: 18))
            .foregroundStyle(Color.black)

          Text("카카오로 시작하기")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Color.black)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color(red: 0.996, green: 0.898, blue: 0.0)) // #FEE500
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }

      // 애플 로그인 버튼
      Button {
        // TODO: 애플 로그인 액션
      } label: {
        HStack(spacing: 6) {
          Image(systemName: "applelogo")
            .font(.system(size: 18))
            .foregroundStyle(Color.white)

          Text("Apple로 시작하기")
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(Color.white)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 56)
        .background(Color.black)
        .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
    .frame(maxWidth: .infinity)
  }

  private var bottomTermsSection: some View {
    VStack(spacing: 0) {
      HStack(spacing: 2) {
        Text("로그인하면 오더런의")
        Text("이용약관")
          .underline()
        Text("및")
      }

      HStack(spacing: 2) {
        Text("개인정보처리방침")
          .underline()
        Text("에 동의하게 됩니다")
      }
    }
    .font(.system(size: 12))
    .foregroundStyle(Color(UIColor.gray600)) // #6A7282
    .multilineTextAlignment(.center)
    .frame(maxWidth: .infinity)
  }
}

#Preview {
  LoginView(
    viewModel: LoginViewModel(
      loginUseCase: LoginUseCase(authRepository: AuthRepositoryImpl())
    )
  )
}
