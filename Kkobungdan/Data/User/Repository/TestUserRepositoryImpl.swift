//
//  TestUserRepositoryImpl.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor TestUserRepositoryImpl: UserRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  private var currentUser: User = .dummy

  func fetchUserDetail() async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return currentUser
  }

  func updateName(_ name: String) async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    currentUser = User(
      id: currentUser.id,
      name: name,
      level: currentUser.level,
      alarmEnabled: currentUser.alarmEnabled
    )
    return currentUser
  }

  func updateAlarm(enabled: Bool) async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    currentUser = User(
      id: currentUser.id,
      name: currentUser.name,
      level: currentUser.level,
      alarmEnabled: enabled
    )
    return currentUser
  }

  func updateFcmToken(_: String) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
  }
}
