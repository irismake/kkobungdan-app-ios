//
//  MarkAllChatRoomsReadUseCase.swift
//  Kkobungdan
//

import Foundation

struct MarkAllChatRoomsReadUseCase {
  private let repository: ChatRepositoryProtocol

  init(repository: ChatRepositoryProtocol) {
    self.repository = repository
  }

  func execute() async throws {
    try await repository.markAllAsRead()
  }
}
