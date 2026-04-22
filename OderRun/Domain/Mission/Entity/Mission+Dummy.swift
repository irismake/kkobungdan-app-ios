//
//  Mission+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension Mission {
  static let dummyList: [Mission] = {
    let now = Date()
    return [
      // 내가 ORDERER — 진행 중
      Mission(
        id: 100, offerID: 40, proposalID: 5,
        ordererID: DummySession.currentUserID, runnerID: "user-r002",
        status: .inProgress, runFee: 8000, itemPrice: 23000,
        proofImageURL: nil, createdAt: now.addingTimeInterval(-86400)
      ),
      // 내가 RUNNER — 전달 완료
      Mission(
        id: 101, offerID: 30, proposalID: 4,
        ordererID: "user-a001", runnerID: DummySession.currentUserID,
        status: .deliveryCompleted, runFee: 2500, itemPrice: 0,
        proofImageURL: "https://cdn.orderrun.com/proofs/mission-101.jpg",
        createdAt: now.addingTimeInterval(-2 * 86400)
      ),
      // 내가 ORDERER — 완료
      Mission(
        id: 102, offerID: 9001, proposalID: 998,
        ordererID: DummySession.currentUserID, runnerID: "user-r001",
        status: .receivedConfirmed, runFee: 5000, itemPrice: 15000,
        proofImageURL: "https://cdn.orderrun.com/proofs/mission-102.jpg",
        createdAt: now.addingTimeInterval(-4 * 86400)
      ),
      // 내가 RUNNER — 분쟁
      Mission(
        id: 103, offerID: 9002, proposalID: 999,
        ordererID: "user-a002", runnerID: DummySession.currentUserID,
        status: .disputed, runFee: 3000, itemPrice: 0,
        proofImageURL: nil, createdAt: now.addingTimeInterval(-7 * 86400)
      )
    ]
  }()

  static var dummy: Mission {
    dummyList[0]
  }
}
