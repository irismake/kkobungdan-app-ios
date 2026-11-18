//
//  SendChatMessageUseCase.swift
//  Kkobungdan
//

import Foundation

struct SendChatMessageUseCase {
  private let repository: ChatRepositoryProtocol

  init(repository: ChatRepositoryProtocol) {
    self.repository = repository
  }

  func execute(roomID: Int64, text: String) async throws -> ChatMessage {
    try await repository.sendMessage(roomID: roomID, text: text)
  }
}
