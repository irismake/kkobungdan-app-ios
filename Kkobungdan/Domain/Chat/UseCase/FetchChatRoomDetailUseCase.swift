//
//  FetchChatRoomDetailUseCase.swift
//  Kkobungdan
//

import Foundation

struct FetchChatRoomDetailUseCase {
  private let repository: ChatRepositoryProtocol

  init(repository: ChatRepositoryProtocol) {
    self.repository = repository
  }

  func execute(roomID: Int64) async throws -> ChatRoomDetail {
    try await repository.fetchChatRoom(roomID: roomID)
  }
}
