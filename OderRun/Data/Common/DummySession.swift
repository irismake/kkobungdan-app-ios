//
//  DummySession.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  TODO: 실제 네트워크 연동 시 삭제. 더미 RepositoryImpl 들이 공유하는 "현재 로그인 유저" 상수.
//

import Foundation

enum DummySession {
  static let currentUserID: String = "me-001"
  static let accessToken: String = "access-token-dummy"
  static let refreshToken: String = "refresh-token-dummy"
}
