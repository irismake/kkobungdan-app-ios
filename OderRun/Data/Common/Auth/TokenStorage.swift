//
//  TokenStorage.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

final class TokenStorage {
  static let shared = TokenStorage()

  private let defaults = UserDefaults.standard
  private let accessKey = "orderrun.accessToken"
  private let refreshKey = "orderrun.refreshToken"

  var accessToken: String? {
    get { defaults.string(forKey: accessKey) }
    set { defaults.set(newValue, forKey: accessKey) }
  }

  var refreshToken: String? {
    get { defaults.string(forKey: refreshKey) }
    set { defaults.set(newValue, forKey: refreshKey) }
  }

  func clear() {
    defaults.removeObject(forKey: accessKey)
    defaults.removeObject(forKey: refreshKey)
  }

  private init() {}
}
