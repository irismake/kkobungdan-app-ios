//
//  TokenStorage.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog

private let tokenLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Auth")

final class TokenStorage {
  static let shared = TokenStorage()

  private let defaults = UserDefaults.standard
  private let accessKey = "orderrun.accessToken"
  private let refreshKey = "orderrun.refreshToken"
  private let userIDKey = "orderrun.userID"
  private let tokenTypeKey = "orderrun.tokenType"

  var accessToken: String? {
    get { defaults.string(forKey: accessKey) }
    set {
      defaults.set(newValue, forKey: accessKey)
      // 토큰 값은 남기지 않는다 (저장 · 삭제 여부만).
      let action = newValue == nil ? "삭제" : "저장"
      tokenLogger.debug("access token \(action, privacy: .public)")
    }
  }

  var refreshToken: String? {
    get { defaults.string(forKey: refreshKey) }
    set { defaults.set(newValue, forKey: refreshKey) }
  }

  var userID: String? {
    get { defaults.string(forKey: userIDKey) }
    set { defaults.set(newValue, forKey: userIDKey) }
  }

  /// Authorization 헤더 스킴(예: "Bearer"). 미저장 시 호출부에서 "Bearer" 로 폴백한다.
  var tokenType: String? {
    get { defaults.string(forKey: tokenTypeKey) }
    set { defaults.set(newValue, forKey: tokenTypeKey) }
  }

  func clear() {
    defaults.removeObject(forKey: accessKey)
    defaults.removeObject(forKey: refreshKey)
    defaults.removeObject(forKey: userIDKey)
    defaults.removeObject(forKey: tokenTypeKey)
  }

  private init() {
    let state = defaults.string(forKey: accessKey) == nil ? "없음" : "있음"
    tokenLogger.debug("저장된 access token \(state, privacy: .public)")
    // 더미 모드에서는 로그인 응답이 없어 userID 가 비어 있다.
    // 더미 데이터가 모두 DummySession.currentUserID 기준이므로 본인 식별자를 맞춰 저장한다.
    if DIContainer.isDummy, userID == nil {
      userID = DummySession.currentUserID
    }
  }
}
