//
//  Offer+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension Offer {
  static let dummyList: [Offer] = {
    let now = Date()
    return [
      // proposal 2 (남의 proposal, OFFERED)
      Offer(id: 10, proposalID: 2, runnerID: "user-r001", status: .waiting, createdAt: now.addingTimeInterval(-86400)),
      Offer(id: 11, proposalID: 2, runnerID: "user-r002", status: .waiting, createdAt: now.addingTimeInterval(-80000)),
      // proposal 3 (내 proposal, OFFERED) — 내가 검토할 지원자들
      Offer(id: 20, proposalID: 3, runnerID: "user-r001", status: .waiting, createdAt: now.addingTimeInterval(-50000)),
      Offer(id: 21, proposalID: 3, runnerID: "user-r002", status: .waiting, createdAt: now.addingTimeInterval(-48000)),
      Offer(id: 22, proposalID: 3, runnerID: "user-r003", status: .rejected, createdAt: now.addingTimeInterval(-47000)),
      // proposal 4 (남의 proposal, MATCHED — 내가 RUNNER로 매칭됨)
      Offer(id: 30, proposalID: 4, runnerID: DummySession.currentUserID, status: .accepted, createdAt: now.addingTimeInterval(-2 * 86400)),
      Offer(id: 31, proposalID: 4, runnerID: "user-r002", status: .rejected, createdAt: now.addingTimeInterval(-2 * 86400 + 1800)),
      // proposal 5 (내 proposal, MATCHED)
      Offer(id: 40, proposalID: 5, runnerID: "user-r002", status: .accepted, createdAt: now.addingTimeInterval(-86400 - 3600)),
      Offer(id: 41, proposalID: 5, runnerID: "user-r003", status: .rejected, createdAt: now.addingTimeInterval(-86400 - 3000)),
      Offer(id: 42, proposalID: 5, runnerID: "user-r001", status: .cancelled, createdAt: now.addingTimeInterval(-86400 - 5000)),
      // 내가 러너로 제출한 offer들
      Offer(id: 50, proposalID: 1, runnerID: DummySession.currentUserID, status: .waiting, createdAt: now.addingTimeInterval(-3600)),
      Offer(id: 51, proposalID: 6, runnerID: DummySession.currentUserID, status: .cancelled, createdAt: now.addingTimeInterval(-2 * 86400 + 3600)),
      // proposal 8 (내 proposal, MATCHED — 완료)
      Offer(id: 60, proposalID: 8, runnerID: "user-r001", status: .accepted, createdAt: now.addingTimeInterval(-4 * 86400)),
      // proposal 9 (남의 proposal, MATCHED — 내가 RUNNER로 분쟁)
      Offer(id: 70, proposalID: 9, runnerID: DummySession.currentUserID, status: .accepted, createdAt: now.addingTimeInterval(-7 * 86400))
    ]
  }()

  static var dummy: Offer {
    dummyList[0]
  }
}
