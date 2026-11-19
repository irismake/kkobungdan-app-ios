//
//  ChatMessage.swift
//  Kkobungdan
//

import Foundation

/// 대화방 메시지 한 개. (서버 API 미구현 — 화면 기준으로 정의, 스펙 확정 시 맞춘다)
/// 채팅 시작·지원 취소·매칭 불성사·완료 대기 같은 안내도 서버가 시스템 메시지로 기록에 남긴다.
struct ChatMessage: Equatable, Identifiable {
  let id: Int64
  let sender: ChatMessageSender
  let text: String
  let sentAt: Date
}

enum ChatMessageSender: Equatable {
  /// 내가 보낸 메시지
  case me
  /// 상대가 보낸 메시지
  case counterpart
  /// 서버 안내 메시지 (가운데 회색 박스)
  case system
}
