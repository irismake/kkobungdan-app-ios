//
//  AuthFlowView.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import SwiftUI

/// 비로그인 상태에서 노출되는 인증 플로우(로그인·회원가입·인증번호 확인).
/// 네비게이션은 `AuthRouter` 가 소유하고, 인증 완료 시 session 만 전환한다.
struct AuthFlowView: View {
  @Environment(SessionViewModel.self) private var session
  /// 인증 플로우 네비게이션 상태(push 스택) + destination 빌더.
  @State private var router = AuthRouter()

  var body: some View {
    NavigationStack(path: $router.path) {
      LoginView(
        onStart: { router.path.append(.signup) },
        onLogin: { router.path.append(.login) }
      )
      .navigationDestination(for: AuthRoute.self) { route in
        router.destination(for: route, onAuthenticated: { session.isLoggedIn = true })
      }
    }
  }
}

#Preview {
  AuthFlowView()
    .environment(SessionViewModel())
}
