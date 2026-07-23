//
//  AppUpdateRepositoryProtocol.swift
//  Kkobungdan
//

import Foundation

protocol AppUpdateRepositoryProtocol {
  /// 원격(Remote Config)에서 최신 업데이트 정책을 가져온다.
  func fetchUpdateConfig() async throws -> AppUpdateConfig
}
