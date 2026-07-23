//
//  FcmTokenStorage.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/20/26.
//
//  Firebase 가 발급한 최신 FCM 토큰의 로컬 저장소.
//  - 로그아웃 상태에서 갱신된 토큰은 여기 보관했다가 로그인/회원가입 confirm 요청에 실어 보낸다.
//  - 토큰은 기기 단위 값이므로 로그아웃해도 지우지 않는다.
//

import Foundation

final class FcmTokenStorage {
  static let shared = FcmTokenStorage()

  private let defaults = UserDefaults.standard
  private let tokenKey = "orderrun.fcmToken"

  var token: String? {
    get { defaults.string(forKey: tokenKey) }
    set { defaults.set(newValue, forKey: tokenKey) }
  }

  private init() {}
}
