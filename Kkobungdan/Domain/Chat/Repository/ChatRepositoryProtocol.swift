//
//  ChatRepositoryProtocol.swift
//  Kkobungdan
//

import Foundation

protocol ChatRepositoryProtocol: Sendable {
  /// 내 대화방 목록(최근 메시지 순).
  func fetchAllChatRooms() async throws -> [ChatRoom]
  /// 특정 요청에 연결된 내 대화방 목록(관련 대화). 상태 포함, 서버가 내 입장에 맞춰 내려준다.
  func fetchChatRooms(proposalID: Int64) async throws -> [ChatRoom]
  /// 모든 대화방을 읽음 처리한다.
  func markAllAsRead() async throws
}
