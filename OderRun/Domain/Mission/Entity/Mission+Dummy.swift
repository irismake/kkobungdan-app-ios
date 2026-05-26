//
//  Mission+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension Mission {
  static let dummyList: [Mission] = [
    // 내가 ORDERER — 전달 완료 (CONFIRM_RECEIVED 가능 상태)
    Mission(
      id: 100, offerID: 40, proposalID: 5,
      orderer: MissionParticipant(id: DummySession.currentUserID, name: "김오더", phone: "010-1111-2222"),
      runner: MissionParticipant(id: "user-r002", name: "이러너", phone: "010-3333-4444"),
      status: .deliveryCompleted,
      runFee: 8000
    ),
    // 내가 RUNNER — 진행 중 (COMPLETE_DELIVERY 가능 상태)
    Mission(
      id: 101, offerID: 30, proposalID: 4,
      orderer: MissionParticipant(id: "user-a001", name: "박오더", phone: "010-5555-6666"),
      runner: MissionParticipant(id: DummySession.currentUserID, name: "나", phone: "010-0000-0000"),
      status: .inProgress,
      runFee: 2500
    ),
    // 내가 ORDERER — 완료
    Mission(
      id: 102, offerID: 60, proposalID: 8,
      orderer: MissionParticipant(id: DummySession.currentUserID, name: "김오더", phone: "010-1111-2222"),
      runner: MissionParticipant(id: "user-r001", name: "최러너", phone: "010-7777-8888"),
      status: .receivedConfirmed,
      runFee: 5000
    ),
    // 내가 RUNNER — 분쟁
    Mission(
      id: 103, offerID: 70, proposalID: 9,
      orderer: MissionParticipant(id: "user-a002", name: "정오더", phone: "010-9999-0000"),
      runner: MissionParticipant(id: DummySession.currentUserID, name: "나", phone: "010-0000-0000"),
      status: .disputed, runFee: 3000
    ),
    // 내가 RUNNER — 매칭 직후, 아직 수행 시작 전 (CREATED)
    Mission(
      id: 104, offerID: 80, proposalID: 10,
      orderer: MissionParticipant(id: "user-a003", name: "홍오더", phone: "010-2222-3333"),
      runner: MissionParticipant(id: DummySession.currentUserID, name: "나", phone: "010-0000-0000"),
      status: .created, runFee: 12000
    ),
    // 내가 ORDERER — 정산까지 완료 (SETTLED)
    Mission(
      id: 105, offerID: 81, proposalID: 11,
      orderer: MissionParticipant(id: DummySession.currentUserID, name: "김오더", phone: "010-1111-2222"),
      runner: MissionParticipant(id: "user-r004", name: "강러너", phone: "010-4444-5555"),
      status: .settled, runFee: 2000
    ),
    // 내가 RUNNER — 환불 처리됨 (REFUNDED)
    Mission(
      id: 106, offerID: 82, proposalID: 12,
      orderer: MissionParticipant(id: "user-a004", name: "윤오더", phone: "010-6666-7777"),
      runner: MissionParticipant(id: DummySession.currentUserID, name: "나", phone: "010-0000-0000"),
      status: .refunded,
      runFee: 3500
    )
  ]

  static var dummy: Mission {
    dummyList[0]
  }
}
