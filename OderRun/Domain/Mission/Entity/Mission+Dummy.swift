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
      // 내가 ORDERER — 전달 완료 (CONFIRM_RECEIVED 가능 상태)
      Mission(
        id: 100, offerID: 40, proposalID: 5,
        ordererID: DummySession.currentUserID, runnerID: "user-r002",
        status: .deliveryCompleted, runFee: 8000, itemPrice: 23000,
        proofImageURL: "https://cdn.orderrun.com/proofs/mission-100.jpg",
        createdAt: now.addingTimeInterval(-86400)
      ),
      // 내가 RUNNER — 진행 중 (COMPLETE_DELIVERY 가능 상태)
      Mission(
        id: 101, offerID: 30, proposalID: 4,
        ordererID: "user-a001", runnerID: DummySession.currentUserID,
        status: .inProgress, runFee: 2500, itemPrice: 0,
        proofImageURL: nil, createdAt: now.addingTimeInterval(-2 * 86400)
      ),
      // 내가 ORDERER — 완료
      Mission(
        id: 102, offerID: 60, proposalID: 8,
        ordererID: DummySession.currentUserID, runnerID: "user-r001",
        status: .receivedConfirmed, runFee: 5000, itemPrice: 15000,
        proofImageURL: "https://cdn.orderrun.com/proofs/mission-102.jpg",
        createdAt: now.addingTimeInterval(-4 * 86400)
      ),
      // 내가 RUNNER — 분쟁
      Mission(
        id: 103, offerID: 70, proposalID: 9,
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
