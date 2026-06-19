//
//  AuthRoute.swift
//  OderRun
//
//  AuthRouter 의 NavigationStack 에서 사용하는 push 라우팅 enum.
//  화면 빌더는 `AuthRouter+Routing`. (메인 탭 라우트는 `AppRoute`)
//

import Foundation

/// 로그인 진입 화면에서 분기되는 인증 경로.
/// `.verification` 은 진입 경로(회원가입/로그인)에 따른 발송·확인 분기를 위해 flow 를 동반한다.
enum AuthRoute: Hashable {
  case signup
  case verification(flow: VerificationCodeViewModel.Flow)
  case login
}
