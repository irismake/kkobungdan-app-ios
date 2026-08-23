//
//  SessionViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

/// 앱 전역 로그인 세션 상태. 홈 / 로그인 화면 분기의 단일 기준이며,
/// SMS·소셜(oauth) 등 인증 수단과 무관하게 "로그인 여부"만 관리한다.
@Observable
final class SessionViewModel {
  var isLoggedIn: Bool

  init(tokenStorage: TokenStorage = .shared) {
    // 더미 모드는 토큰 발급 경로가 없으므로 DummySession 값을 저장해 로그인된 상태로 진입한다.
    // 실 API 모드는 저장된 refresh token 이 있으면 이미 로그인된 상태로 시작.
    // refresh token 도 만료됐다면 첫 API 호출의 401 → refresh 실패 → forceLogout 으로 복귀.
    if DIContainer.isDummy {
      tokenStorage.accessToken = DummySession.accessToken
      tokenStorage.refreshToken = DummySession.refreshToken
      tokenStorage.userID = DummySession.currentUserID
    }
    isLoggedIn = tokenStorage.refreshToken != nil
  }
}
