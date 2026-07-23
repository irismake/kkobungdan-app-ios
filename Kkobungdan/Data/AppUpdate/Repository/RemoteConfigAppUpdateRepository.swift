//
//  RemoteConfigAppUpdateRepository.swift
//  Kkobungdan
//

import FirebaseRemoteConfig
import Foundation
import OSLog

private let updateLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "AppUpdate")

/// Firebase Remote Config 기반 앱 업데이트 정책 리포지토리.
///
/// Firebase 콘솔에 등록하는 파라미터(개별 키):
/// - `ios_min_version` (String) — 이 버전 미만이면 강제 업데이트.
/// - `ios_latest_version` (String) — 이 버전 미만이면 선택 업데이트 권장.
/// - `ios_store_url` (String, 선택) — 스토어 URL. 비면 앱 번들의 App Store ID fallback 사용.
/// - `ios_force_update_message` (String, 선택) — 강제 업데이트 안내 문구.
/// - `ios_optional_update_message` (String, 선택) — 선택 업데이트 안내 문구.
final class RemoteConfigAppUpdateRepository: AppUpdateRepositoryProtocol {
  private enum Key {
    static let minVersion = "ios_min_version"
    static let latestVersion = "ios_latest_version"
    static let storeURL = "ios_store_url"
    static let forceMessage = "ios_force_update_message"
    static let optionalMessage = "ios_optional_update_message"
  }

  /// App Store Connect Apple ID (6786577839). `ios_store_url` 미설정 시 fallback.
  private static let appStoreID = "6786577839"
  private static let fallbackStoreURL = URL(
    string: "https://apps.apple.com/app/id\(appStoreID)"
  )!

  private let remoteConfig: RemoteConfig
  private let fallbackVersion: String

  /// - Parameter fallbackVersion: min/latest 값이 비었을 때 사용할 버전(업데이트 미유발). 기본 현재 앱 버전.
  init(fallbackVersion: String = Bundle.main.appVersion) {
    remoteConfig = RemoteConfig.remoteConfig()
    self.fallbackVersion = fallbackVersion

    // 콜드 스타트마다 최신 정책을 반영하도록 스로틀을 두지 않는다.
    let settings = RemoteConfigSettings()
    settings.minimumFetchInterval = 0
    remoteConfig.configSettings = settings

    // fetch 이전에도 안전한 기본값을 갖도록 in-app 기본값 세팅 (업데이트 미유발).
    remoteConfig.setDefaults([
      Key.minVersion: fallbackVersion as NSString,
      Key.latestVersion: fallbackVersion as NSString
    ])
  }

  func fetchUpdateConfig() async throws -> AppUpdateConfig {
    let status = try await remoteConfig.fetchAndActivate()
    updateLogger.debug("Remote Config fetchAndActivate: \(String(describing: status), privacy: .public)")

    let minVersion = string(for: Key.minVersion) ?? fallbackVersion
    let latestVersion = string(for: Key.latestVersion) ?? fallbackVersion

    let storeURL = (string(for: Key.storeURL).flatMap(URL.init(string:)))
      ?? Self.fallbackStoreURL

    return AppUpdateConfig(
      minimumVersion: minVersion,
      latestVersion: latestVersion,
      storeURL: storeURL,
      forceMessage: string(for: Key.forceMessage),
      optionalMessage: string(for: Key.optionalMessage)
    )
  }

  /// Remote Config 값이 비어 있으면 nil 로 정규화.
  private func string(for key: String) -> String? {
    let value = remoteConfig.configValue(forKey: key).stringValue
    let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }
}
