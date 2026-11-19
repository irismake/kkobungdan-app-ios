//
//  FetchChatRoomsUseCase.swift
//  Kkobungdan
//

import Foundation

struct FetchChatRoomsUseCase {
  private let repository: ChatRepositoryProtocol

  init(repository: ChatRepositoryProtocol) {
    self.repository = repository
  }

  func execute() async throws -> [ChatRoom] {
    try await repository.fetchAllChatRooms()
  }

  /// 요청 상세의 관련 대화.
  func execute(proposalID: Int64) async throws -> [ChatRoom] {
    try await repository.fetchChatRooms(proposalID: proposalID)
  }
}
