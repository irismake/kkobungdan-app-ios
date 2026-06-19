//
//  AuthRouter.swift
//  OderRun
//
//  비로그인 인증 플로우(로그인·회원가입·인증번호 확인)의 네비게이션 상태(push 스택)를 소유한다.
//  화면(AuthFlowView)·비즈니스 VM(AuthFlowViewModel) 과 분리된 순수 네비게이션 레이어.
//  destination 빌더는 `AuthRouter+Routing` 참고. (메인 탭 라우터는 `AppRouter`)
//

import SwiftUI

@Observable
final class AuthRouter {
  var path: [AuthRoute] = []

  func reset() {
    path.removeAll()
  }
}
