//
//  LoginView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

struct LoginView: View {
  /// 본인인증 안내 시트를 띄운 버튼의 의도. 인증 완료 후 분기에 사용.
  private enum VerificationIntent {
    case signup
    case login
  }

  let onStart: () -> Void
  let onLogin: () -> Void

  @State private var verificationIntent: VerificationIntent?

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        Spacer()

        brandSection

        Spacer()

        bottomSection
      }

      if let verificationIntent {
        IdentityVerificationSheet(
          onClose: { self.verificationIntent = nil },
          onVerify: {
            self.verificationIntent = nil
            switch verificationIntent {
            case .signup: onStart()
            case .login: onLogin()
            }
          }
        )
      }
    }
  }

  private var brandSection: some View {
    VStack(spacing: 12) {
      Image("logo")
        .resizable()
        .scaledToFit()
        .frame(width: 96, height: 67)

      VStack(spacing: 8) {
        Text("꼬붕단")
          .textStyle(.display)
          .foregroundColor(.gray900)
          .multilineTextAlignment(.center)

        Text("줄서기부터 쇼핑 동행까지,\n오늘도 꼬붕단 출동!")
          .textStyle(.body1)
          .foregroundColor(.gray600)
          .multilineTextAlignment(.center)
      }
    }
  }

  private var bottomSection: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)

      ScreenContainer {
        VStack(spacing: 10) {
          ConfirmButton(title: "시작하기", action: { verificationIntent = .signup })

          Button(action: { verificationIntent = .login }) {
            HStack(spacing: 2) {
              Text("이미 계정이 있나요?")
                .textStyle(.caption5)
                .foregroundColor(.gray500)

              Text("로그인")
                .textStyle(.caption4)
                .foregroundColor(.indigo500)
            }
            .frame(maxWidth: .infinity)
          }
          .buttonStyle(.plain)
        }
        .padding(.top, 16)
        .padding(.bottom, 32)
      }
    }
  }
}

#Preview {
  LoginView(onStart: {}, onLogin: {})
}
