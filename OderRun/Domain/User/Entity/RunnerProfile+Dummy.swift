//
//  RunnerProfile+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//

import Foundation

extension RunnerProfile {
  static let dummyByID: [String: RunnerProfile] = [
    DummySession.currentUserID: RunnerProfile(id: DummySession.currentUserID, nickname: "길동이", level: 5, grade: "B등급"),
    "user-a001": RunnerProfile(id: "user-a001", nickname: "철수쓰", level: 3, grade: "C등급"),
    "user-a002": RunnerProfile(id: "user-a002", nickname: "영희짱", level: 7, grade: "A등급"),
    "user-r001": RunnerProfile(id: "user-r001", nickname: "민수형", level: 4, grade: "B등급"),
    "user-r002": RunnerProfile(id: "user-r002", nickname: "지현님", level: 6, grade: "A등급"),
    "user-r003": RunnerProfile(id: "user-r003", nickname: "준호야", level: 2, grade: "C등급")
  ]
}
