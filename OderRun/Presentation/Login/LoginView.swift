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
          .odrStyle(.headline2(weight: .bold, color: Color.gray900))

        Text("내용")
          .odrStyle(.body1(weight: .regular, color: Color.gray600))
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
            .odrStyle(.body1(color: .black))
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
            .odrStyle(.body1(color: .white))
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
          .odrStyle(.caption1(color: Color.gray500))
        Text("이용약관")
          .odrStyle(.caption1(color: Color.gray500))
          .underline()
        Text("및")
          .odrStyle(.caption1(color: Color.gray500))
      }
      HStack(spacing: 2) {
        Text("개인정보처리방침")
          .odrStyle(.caption1(color: Color.gray500))
          .underline()
        Text("에 동의하게 됩니다")
          .odrStyle(.caption1(color: Color.gray500))
      }
    }
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
