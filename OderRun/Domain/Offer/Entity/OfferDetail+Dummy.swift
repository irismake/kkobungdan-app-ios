//
//  OfferDetail+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 5/19/26.
//

import Foundation

extension OfferDetail {
  /// 더미 환경에서 runnerID → 표시용 프로필 매핑.
  static let runnerProfileByID: [String: (nickname: String, level: Int, grade: String)] = [
    DummySession.currentUserID: ("길동이", 5, "B등급"),
    "user-a001": ("철수쓰", 3, "C등급"),
    "user-a002": ("영희짱", 7, "A등급"),
    "user-r001": ("민수형", 4, "B등급"),
    "user-r002": ("지현님", 6, "A등급"),
    "user-r003": ("준호야", 2, "C등급")
  ]

  static func dummyProfile(for runnerID: String) -> (nickname: String, level: Int, grade: String) {
    runnerProfileByID[runnerID] ?? ("러너", 1, "C등급")
  }
}
