//
//  ChatRoomDetail.swift
//  Kkobungdan
//

import Foundation

/// 채팅 상세 화면의 대화방 정보. (서버 API 미구현 — 화면 기준으로 정의, 스펙 확정 시 맞춘다)
/// 대화방은 지원(offer) 1건당 1개라 `id` 는 지원 ID 와 같다.
struct ChatRoomDetail: Equatable {
  /// 대화방이 연결된 지원 ID
  let id: Int64
  let proposalID: Int64
  let proposalTitle: String
  let errandFee: Int
  let deadline: Date
  /// 대화 상대 이름. 상대가 탈퇴했으면 서버가 탈퇴 표시 이름으로 내려준다.
  let counterpartName: String
  /// 이 대화방에서 나의 입장
  let myRole: ChatRole
  /// 대화방의 현재 상태. 서버가 내 입장(행님/꼬붕)에 맞춰 내려준다.
  let status: ChatRoomStatus
  /// 진행중 미션에서 내가 이미 '임무 수행 완료'를 눌렀는지. 양측이 모두 누르면 미션 완료.
  let didICompleteMission: Bool
}

/// 대화방에서 나의 입장.
enum ChatRole: Equatable {
  /// 행님 (요청자)
  case orderer
  /// 꼬붕 (지원자)
  case runner
}

extension ChatRoomDetail {
  /// 메시지를 보낼 수 있는 상태. 대기중·진행중에만 열려 있다.
  /// 진행중에 한쪽만 '임무 수행 완료'를 눌렀어도 계속 보낼 수 있고,
  /// 양측 완료(완료)·중단 신청(분쟁중)·취소가 되면 종료된다.
  var canSendMessage: Bool {
    status == .waiting || status == .inProgress
  }
}
