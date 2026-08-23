//
//  AppUpdateConfig.swift
//  Kkobungdan
//

import Foundation

/// Remote Config 로부터 받아오는 앱 업데이트 정책.
/// - `minimumVersion`: 이 버전 미만이면 강제 업데이트(앱 사용 차단).
/// - `latestVersion`: 이 버전 미만이면 선택 업데이트 권장(닫기 가능).
struct AppUpdateConfig: Equatable {
  let minimumVersion: String
  let latestVersion: String
  let storeURL: URL
  let forceMessage: String?
  let optionalMessage: String?
}
