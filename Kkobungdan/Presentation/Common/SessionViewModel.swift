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

  /// 강제 로그아웃 신호 구독. 앱 시작 시점부터 살아 있는 이 객체가 직접 받아야
  /// 스플래시 중(ContentView 가 아직 없을 때) 온 신호도 놓치지 않는다.
  @ObservationIgnored private var forcedLogoutObserver: NSObjectProtocol?
  @ObservationIgnored private let notificationCenter: NotificationCenter

  init(
    tokenStorage: TokenStorage = .shared,
    notificationCenter: NotificationCenter = .default
  ) {
    // 더미 모드는 토큰 발급 경로가 없으므로 DummySession 값을 저장해 로그인된 상태로 진입한다.
    // 실 API 모드는 저장된 refresh token 이 있으면 이미 로그인된 상태로 시작.
    // refresh token 도 만료됐다면 첫 API 호출의 401 → refresh 실패 → forceLogout 으로 복귀.
    if DIContainer.isDummy {
      tokenStorage.accessToken = DummySession.accessToken
      tokenStorage.refreshToken = DummySession.refreshToken
      tokenStorage.userID = DummySession.currentUserID
    }
    isLoggedIn = tokenStorage.refreshToken != nil

    self.notificationCenter = notificationCenter
    forcedLogoutObserver = notificationCenter.addObserver(
      forName: .authForcedLogout,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      self?.isLoggedIn = false
    }
  }

  deinit {
    if let forcedLogoutObserver {
      notificationCenter.removeObserver(forcedLogoutObserver)
    }
  }
}
