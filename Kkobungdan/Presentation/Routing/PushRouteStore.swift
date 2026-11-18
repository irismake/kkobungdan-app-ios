//
//  PushRouteStore.swift
//  Kkobungdan
//
//  푸시 배너 탭으로 들어온 payload 를 UI(라우터)가 소비할 때까지 보관한다.
//  콜드 스타트(앱 종료 상태에서 탭)에서도 메인 탭이 뜬 뒤 꺼내 쓸 수 있다.
//

import Foundation

@Observable
@MainActor
final class PushRouteStore {
  static let shared = PushRouteStore()

  /// 아직 라우팅되지 않은 푸시 딥링크. 소비 측이 이동 처리 후 nil 로 되돌린다.
  var pending: PushPayload?

  /// 포그라운드에서 푸시가 도착할 때마다 증가. 홈 알림 뱃지·알림 목록 갱신 트리거.
  var foregroundPushCount = 0
}
