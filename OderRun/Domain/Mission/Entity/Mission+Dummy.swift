//
//  Mission+Dummy.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

extension MissionParticipant {
  /// 더미 백엔드용 userID → 참여자 매핑. `Mission+Dummy` fixture 와 `DummyBackendStore.acceptOffer`
  /// 에서 새 미션을 만들 때 동일하게 참조해 name/phone 누락을 방지한다.
  nonisolated static let dummyByUserID: [String: MissionParticipant] = [
    DummySession.currentUserID: MissionParticipant(id: DummySession.currentUserID, name: "김오더", phone: "010-1111-2222"),
    "user-a001": MissionParticipant(id: "user-a001", name: "박오더", phone: "010-5555-6666"),
    "user-a002": MissionParticipant(id: "user-a002", name: "정오더", phone: "010-9999-0000"),
    "user-a003": MissionParticipant(id: "user-a003", name: "홍오더", phone: "010-2222-3333"),
    "user-a004": MissionParticipant(id: "user-a004", name: "윤오더", phone: "010-6666-7777"),
    "user-r001": MissionParticipant(id: "user-r001", name: "최러너", phone: "010-7777-8888"),
    "user-r002": MissionParticipant(id: "user-r002", name: "이러너", phone: "010-3333-4444"),
    "user-r003": MissionParticipant(id: "user-r003", name: "박러너", phone: "010-8888-9999"),
    "user-r004": MissionParticipant(id: "user-r004", name: "강러너", phone: "010-4444-5555")
  ]

  /// 매핑에 없으면 id 만 채우고 name/phone 은 빈 문자열로 둔다.
  nonisolated static func dummy(for userID: String) -> MissionParticipant {
    dummyByUserID[userID] ?? MissionParticipant(id: userID, name: "", phone: "")
  }
}

extension Mission {
  static let dummyList: [Mission] = [
    // 내가 ORDERER — 전달 완료 (CONFIRM_RECEIVED 가능 상태)
    Mission(
      id: 100, offerID: 40, proposalID: 5,
      orderer: .dummy(for: DummySession.currentUserID),
      runner: .dummy(for: "user-r002"),
      status: .deliveryCompleted
    ),
    // 내가 RUNNER — 진행 중 (COMPLETE_DELIVERY 가능 상태)
    Mission(
      id: 101, offerID: 30, proposalID: 4,
      orderer: .dummy(for: "user-a001"),
      runner: .dummy(for: DummySession.currentUserID),
      status: .inProgress
    ),
    // 내가 ORDERER — 정산 완료 (cascade: mission .settled + offer/proposal .complete)
    Mission(
      id: 102, offerID: 60, proposalID: 8,
      orderer: .dummy(for: DummySession.currentUserID),
      runner: .dummy(for: "user-r001"),
      status: .settled
    ),
    // 내가 RUNNER — 분쟁 (offer/proposal 은 진행 상태 유지)
    Mission(
      id: 103, offerID: 70, proposalID: 9,
      orderer: .dummy(for: "user-a002"),
      runner: .dummy(for: DummySession.currentUserID),
      status: .disputed
    ),
    // 내가 RUNNER — 매칭 직후, 아직 수행 시작 전 (CREATED)
    Mission(
      id: 104, offerID: 80, proposalID: 10,
      orderer: .dummy(for: "user-a003"),
      runner: .dummy(for: DummySession.currentUserID),
      status: .created
    ),
    // 내가 ORDERER — 정산까지 완료 (SETTLED)
    Mission(
      id: 105, offerID: 81, proposalID: 11,
      orderer: .dummy(for: DummySession.currentUserID),
      runner: .dummy(for: "user-r004"),
      status: .settled
    ),
    // 내가 RUNNER — 환불 처리됨 (REFUNDED, offer/proposal 도 terminal 로 정합)
    Mission(
      id: 106, offerID: 82, proposalID: 12,
      orderer: .dummy(for: "user-a004"),
      runner: .dummy(for: DummySession.currentUserID),
      status: .refunded
    )
  ]

  static var dummy: Mission {
    dummyList[0]
  }
}
