//
//  AppUpdateViewModel.swift
//  Kkobungdan
//

import Foundation
import OSLog

private let updateLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "AppUpdate")

/// 앱 시작 시 Remote Config 업데이트 정책을 조회해 강제/선택 업데이트 상태를 노출한다.
@MainActor
@Observable
final class AppUpdateViewModel {
  private(set) var status: AppUpdateStatus = .upToDate
  /// 선택 업데이트를 "나중에" 로 닫았는지 (강제 업데이트에는 영향 없음).
  var isOptionalDismissed = false

  private let useCase: CheckAppUpdateUseCase

  init(useCase: CheckAppUpdateUseCase = CheckAppUpdateUseCase(repository: DIContainer.appUpdateRepository)) {
    self.useCase = useCase
  }

  func check() async {
    do {
      let result = try await useCase.execute()
      status = result
      updateLogger.info("업데이트 상태 판정: \(String(describing: result), privacy: .public)")
    } catch {
      // 조회 실패 시 사용을 막지 않는다 (fail-safe).
      updateLogger.error("업데이트 상태 조회 실패: \(error)")
      status = .upToDate
    }
  }
}
