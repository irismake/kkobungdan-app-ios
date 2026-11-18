//
//  ChatRepository.swift
//  Kkobungdan
//
//  실 API 구현. 서버 채팅 API 가 아직 없어 빈 목록을 돌려준다.
//

import Foundation

final class ChatRepository: ChatRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  // TODO: 서버 채팅 목록 API 확정 시 응답 DTO 추가 후 연동
  func fetchAllChatRooms() async throws -> [ChatRoom] {
    []
  }

  // TODO: 서버 요청별 관련 대화 API 확정 시 연동
  func fetchChatRooms(proposalID _: Int64) async throws -> [ChatRoom] {
    []
  }

  // TODO: 서버 채팅 읽음 처리 API 확정 시 연동
  func markAllAsRead() async throws {}

  // TODO: 서버 대화방 상세 API 확정 시 응답 DTO 추가 후 연동
  func fetchChatRoom(roomID _: Int64) async throws -> ChatRoomDetail {
    throw RepositoryError.notImplemented
  }

  // TODO: 서버 메시지 목록 API 확정 시 응답 DTO 추가 후 연동
  func fetchMessages(roomID _: Int64) async throws -> [ChatMessage] {
    throw RepositoryError.notImplemented
  }

  // TODO: 서버 메시지 전송 API 확정 시 요청 바디·응답 DTO 추가 후 연동
  func sendMessage(roomID _: Int64, text _: String) async throws -> ChatMessage {
    throw RepositoryError.notImplemented
  }
}
