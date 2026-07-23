//
//  Bundle+AppVersion.swift
//  Kkobungdan
//

import Foundation

extension Bundle {
  /// 현재 앱의 마케팅 버전 (`CFBundleShortVersionString`, 예: "1.0.0").
  nonisolated var appVersion: String {
    object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.0.0"
  }
}
