//
//  FetchChatMessagesUseCase.swift
//  Kkobungdan
//

import Foundation

struct FetchChatMessagesUseCase {
  private let repository: ChatRepositoryProtocol

  init(repository: ChatRepositoryProtocol) {
    self.repository = repository
  }

  func execute(roomID: Int64) async throws -> [ChatMessage] {
    try await repository.fetchMessages(roomID: roomID)
  }
}
