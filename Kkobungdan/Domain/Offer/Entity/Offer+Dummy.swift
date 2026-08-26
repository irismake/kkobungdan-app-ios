//
//  Offer+Dummy.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension Offer {
  static let dummyList: [Offer] = {
    let now = Date()
    /// runnerName 은 서버 목록 응답 필드. 더미는 runnerID → 참여자 이름으로 채운다.
    func make(id: Int64, proposalID: Int64, runnerID: String, status: OfferStatus, createdAt: Date) -> Offer {
      Offer(
        id: id,
        proposalID: proposalID,
        runnerID: runnerID,
        runnerName: DummySession.displayName(for: runnerID),
        runnerLevel: DummySession.level(for: runnerID),
        status: status,
        createdAt: createdAt
      )
    }
    return [
      // proposal 2 (남의 proposal, OFFERED)
      make(id: 10, proposalID: 2, runnerID: "user-r001", status: .waiting, createdAt: now.addingTimeInterval(-86400)),
      make(id: 11, proposalID: 2, runnerID: "user-r002", status: .waiting, createdAt: now.addingTimeInterval(-80000)),
      // proposal 3 (내 proposal, OFFERED) — 내가 검토할 지원자들
      make(id: 20, proposalID: 3, runnerID: "user-r001", status: .waiting, createdAt: now.addingTimeInterval(-50000)),
      make(id: 21, proposalID: 3, runnerID: "user-r002", status: .waiting, createdAt: now.addingTimeInterval(-48000)),
      make(id: 22, proposalID: 3, runnerID: "user-r003", status: .rejected, createdAt: now.addingTimeInterval(-47000)),
      // proposal 4 (남의 proposal, MATCHED — 내가 RUNNER로 매칭됨)
      make(id: 30, proposalID: 4, runnerID: DummySession.currentUserID, status: .accepted, createdAt: now.addingTimeInterval(-2 * 86400)),
      make(id: 31, proposalID: 4, runnerID: "user-r002", status: .rejected, createdAt: now.addingTimeInterval(-2 * 86400 + 1800)),
      // proposal 5 (내 proposal, MATCHED)
      make(id: 40, proposalID: 5, runnerID: "user-r002", status: .accepted, createdAt: now.addingTimeInterval(-86400 - 3600)),
      make(id: 41, proposalID: 5, runnerID: "user-r003", status: .rejected, createdAt: now.addingTimeInterval(-86400 - 3000)),
      make(id: 42, proposalID: 5, runnerID: "user-r001", status: .cancelled, createdAt: now.addingTimeInterval(-86400 - 5000)),
      // 내가 러너로 제출한 offer들
      make(id: 50, proposalID: 1, runnerID: DummySession.currentUserID, status: .waiting, createdAt: now.addingTimeInterval(-3600)),
      make(id: 51, proposalID: 6, runnerID: DummySession.currentUserID, status: .cancelled, createdAt: now.addingTimeInterval(-2 * 86400 + 3600)),
      // proposal 8 (내 proposal, ALL_COMPLETED — 완료)
      make(id: 60, proposalID: 8, runnerID: "user-r001", status: .allCompleted, createdAt: now.addingTimeInterval(-4 * 86400)),
      // proposal 9 (남의 proposal, MATCHED — 내가 RUNNER로 분쟁)
      make(id: 70, proposalID: 9, runnerID: DummySession.currentUserID, status: .accepted, createdAt: now.addingTimeInterval(-7 * 86400)),
      // proposal 10 (남의 proposal, MATCHED — 내가 RUNNER, 미션 CREATED 직후)
      make(id: 80, proposalID: 10, runnerID: DummySession.currentUserID, status: .accepted, createdAt: now.addingTimeInterval(-3600)),
      // proposal 11 (내 proposal, ALL_COMPLETED — 정산 완료)
      make(id: 81, proposalID: 11, runnerID: "user-r004", status: .allCompleted, createdAt: now.addingTimeInterval(-10 * 86400)),
      // proposal 12 (남의 proposal, REFUNDED — 내가 RUNNER, 분쟁이 환불로 종결된 terminal cascade)
      make(id: 82, proposalID: 12, runnerID: DummySession.currentUserID, status: .cancelled, createdAt: now.addingTimeInterval(-12 * 86400))
    ]
  }()

  static var dummy: Offer {
    dummyList[0]
  }
}
