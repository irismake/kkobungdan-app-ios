//
//  User+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension User {
  static let dummy = User(
    id: DummySession.currentUserID,
    name: "홍길동",
    level: DummySession.level(for: DummySession.currentUserID),
    alarmEnabled: true
  )
}
