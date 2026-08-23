//
//  AppUpdateStatus.swift
//  Kkobungdan
//

import Foundation

/// 현재 설치 버전을 Remote Config 정책과 비교한 결과.
enum AppUpdateStatus: Equatable {
  /// 최신 상태 — 업데이트 안내 불필요.
  case upToDate
  /// 선택 업데이트 — 닫고 계속 사용 가능.
  case optional(storeURL: URL, message: String)
  /// 강제 업데이트 — 스토어 이동 외 다른 조작 차단.
  case forced(storeURL: URL, message: String)
}
