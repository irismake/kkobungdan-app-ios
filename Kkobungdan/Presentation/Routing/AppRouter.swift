//
//  AppRouter.swift
//  Kkobungdan
//
//  메인 탭의 네비게이션 상태(선택 탭 + 탭별 push 스택)를 소유한다.
//  화면(MainTabView)·VM 과 분리된 순수 네비게이션 레이어.
//  destination 빌더는 `AppRouter+Routing` / `AppRouter+AddProposalRouting` 참고.
//

import SwiftUI

@Observable
final class AppRouter {
  var selectedTab: HomeTab = .home
  var homePath: [AppRoute] = []
  var activityPath: [AppRoute] = []
  var activitySegment: ActivitySegment = .orderer
  var activityFilter: ActivityStatusFilter = .all

  func popLast(path: Binding<[AppRoute]>) {
    if !path.wrappedValue.isEmpty {
      path.wrappedValue.removeLast()
    }
  }
}
