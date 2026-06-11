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

  /// userID → 표시 이름. 서버 응답의 runnerName 등을 더미에서 채울 때 사용한다.
  static func displayName(for userID: String) -> String {
    switch userID {
    case currentUserID: return "나"
    case "user-r001": return "성실한치타"
    case "user-r002": return "부지런한여우"
    case "user-r003": return "친절한곰"
    case "user-r004": return "빠른제비"
    case "user-a001": return "이웃주민1"
    case "user-a002": return "이웃주민2"
    case "user-a003": return "이웃주민3"
    case "user-a004": return "이웃주민4"
    default: return "러너"
    }
  }
}
