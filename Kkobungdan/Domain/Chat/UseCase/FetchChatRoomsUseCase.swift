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
    try await repository.fetchChatRooms()
  }
}
