//
//  AuthRouter+Routing.swift
//  Kkobungdan
//
//  AuthRoute → 화면 push 빌더. 인증번호 발송은 verification 화면 진입 후 `VerificationCodeViewModel` 이 직접 수행한다.
//

import SwiftUI

extension AuthRouter {
  /// - Parameter onAuthenticated: 인증 완료 시 session 전환 콜백. session 환경은 View 가 가지므로 주입받는다.
  @ViewBuilder
  func destination(for route: AuthRoute, onAuthenticated: @escaping () -> Void) -> some View {
    switch route {
    case .signup:
      SignupView(
        onClose: { self.reset() },
        onComplete: { name, phone, carrier in
          self.path.append(.verification(flow: .signup(name: name, phone: phone, carrier: carrier)))
        }
      )
    case let .verification(flow):
      VerificationCodeView(
        viewModel: AppRouteFactory.makeVerificationViewModel(flow: flow),
        onClose: { self.reset() },
        onComplete: onAuthenticated
      )
    case .login:
      SmsLoginView(
        onClose: { self.reset() },
        onNext: { phone in
          self.path.append(.verification(flow: .login(phone: phone)))
        },
        onFindAccount: {
          // TODO: 내 계정 찾기 — 회원가입과 같은 본인인증 flow 진행
        }
      )
    }
  }
}
