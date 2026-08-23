//
//  TestAppUpdateRepositoryImpl.swift
//  Kkobungdan
//

import Foundation

/// 더미 모드용 업데이트 리포지토리. 항상 최신 상태로 취급해 업데이트 안내를 띄우지 않는다.
/// 강제/선택 업데이트 UI 를 확인하려면 `minimumVersion`/`latestVersion` 값을 높게 조정한다.
actor TestAppUpdateRepositoryImpl: AppUpdateRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 300_000_000

  func fetchUpdateConfig() async throws -> AppUpdateConfig {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let current = Bundle.main.appVersion
    return AppUpdateConfig(
      minimumVersion: current,
      latestVersion: current,
      storeURL: URL(string: "https://apps.apple.com/app/id6786577839")!,
      forceMessage: nil,
      optionalMessage: nil
    )
  }
}
