//
//  ChatRoom.swift
//  Kkobungdan
//

import Foundation

/// 채팅 목록의 대화방 한 개. (서버 API 미구현 — 화면 기준으로 정의, 스펙 확정 시 맞춘다)
/// 대화방은 지원(offer) 1건당 1개 — 지원 시 자동 생성되고, 지원이 취소·환불돼도 삭제되지 않는다.
struct ChatRoom: Equatable, Identifiable {
  /// 대화방이 연결된 지원 ID
  let id: Int64
  let proposalID: Int64
  /// 대화 상대 이름 (내가 지원자면 요청자, 요청자면 지원자)
  let counterpartName: String
  /// 대화가 연결된 요청 제목
  let proposalTitle: String
  let lastMessage: String
  let lastMessageAt: Date
  /// 대화방의 현재 상태. 서버가 내 입장(행님/꼬붕)에 맞춰 내려준다.
  let status: ChatRoomStatus
  let unreadCount: Int
}

/// 대화방 현재 상태. 화면에서는 요청·수행 기록 카드와 같은 배지로 보여준다.
enum ChatRoomStatus: Equatable {
  /// 대기중
  case waiting
  /// 진행중
  case inProgress
  /// 완료
  case completed
  /// 취소 (지원 취소·미선정·요청 취소·환불 등)
  case cancelled
  /// 분쟁중
  case disputed
}
