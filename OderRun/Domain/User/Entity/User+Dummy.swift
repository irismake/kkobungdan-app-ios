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
    email: "me@orderrun.com",
    name: "홍길동",
    phone: "010-1234-5678",
    createdAt: Date(),
    lastLoginAt: Date(),
    alarmEnabled: true,
    nickname: "길동이",
    level: 5,
    grade: "B등급"
  )
}
