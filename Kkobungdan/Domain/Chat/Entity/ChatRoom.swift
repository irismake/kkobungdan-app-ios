//
//  ChatRoom.swift
//  Kkobungdan
//

import Foundation

/// 채팅 목록의 대화방 한 개. (서버 API 미구현 — 화면 기준으로 정의, 스펙 확정 시 맞춘다)
/// 상태 배지는 요청·지원 상태로 결정한다 — `ActivityStatusBadge.badges(chatRoom:)`.
struct ChatRoom: Equatable, Identifiable {
  let id: Int64
  /// 대화 상대 이름
  let counterpartName: String
  /// 대화가 연결된 요청 제목
  let proposalTitle: String
  let lastMessage: String
  let lastMessageAt: Date
  /// 연결된 요청의 상태
  let proposalStatus: ProposalStatus
  /// 내가 지원자인 대화면 내 지원 상태, 내가 요청자면 nil
  let myOfferStatus: OfferStatus?
  let unreadCount: Int
}
