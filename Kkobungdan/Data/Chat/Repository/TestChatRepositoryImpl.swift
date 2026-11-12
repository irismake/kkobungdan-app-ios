//
//  TestChatRepositoryImpl.swift
//  Kkobungdan
//
//  더미 전용. 지연 시뮬레이션 후 DummyBackendStore 에 위임한다.
//

import Foundation

final class TestChatRepositoryImpl: ChatRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 300_000_000
  private let store: DummyBackendStore

  init(store: DummyBackendStore) {
    self.store = store
  }

  func fetchAllChatRooms() async throws -> [ChatRoom] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchAllChatRooms()
  }

  func fetchChatRooms(proposalID: Int64) async throws -> [ChatRoom] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchChatRooms(proposalID: proposalID)
  }

  func markAllAsRead() async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    await store.markAllChatRoomsAsRead()
  }
}
