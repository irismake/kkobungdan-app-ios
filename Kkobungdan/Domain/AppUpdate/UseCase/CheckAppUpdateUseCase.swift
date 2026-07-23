//
//  CheckAppUpdateUseCase.swift
//  Kkobungdan
//

import Foundation

/// 현재 설치 버전과 Remote Config 정책을 비교해 업데이트 필요 여부를 판정한다.
///
/// 판정 규칙:
/// - `current < minimumVersion` → `.forced` (앱 사용 차단)
/// - `minimumVersion <= current < latestVersion` → `.optional` (권장, 닫기 가능)
/// - `current >= latestVersion` → `.upToDate`
struct CheckAppUpdateUseCase {
  private let repository: AppUpdateRepositoryProtocol
  private let currentVersion: String

  init(
    repository: AppUpdateRepositoryProtocol,
    currentVersion: String = Bundle.main.appVersion
  ) {
    self.repository = repository
    self.currentVersion = currentVersion
  }

  func execute() async throws -> AppUpdateStatus {
    let config = try await repository.fetchUpdateConfig()
    let current = AppVersion(currentVersion)

    if current < AppVersion(config.minimumVersion) {
      return .forced(
        storeURL: config.storeURL,
        message: config.forceMessage ?? Self.defaultForceMessage
      )
    }

    if current < AppVersion(config.latestVersion) {
      return .optional(
        storeURL: config.storeURL,
        message: config.optionalMessage ?? Self.defaultOptionalMessage
      )
    }

    return .upToDate
  }
}

extension CheckAppUpdateUseCase {
  static let defaultForceMessage =
    "원활한 이용을 위해 최신 버전으로 업데이트해 주세요.\n업데이트 후 다시 이용하실 수 있어요."
  static let defaultOptionalMessage =
    "새로운 기능과 개선된 환경을 위해\n최신 버전으로 업데이트해 주세요."
}
