//
//  ChatRepositoryProtocol.swift
//  Kkobungdan
//

import Foundation

protocol ChatRepositoryProtocol: Sendable {
  /// 내 대화방 목록(최근 메시지 순).
  func fetchChatRooms() async throws -> [ChatRoom]
  /// 모든 대화방을 읽음 처리한다.
  func markAllAsRead() async throws
}
