//
//  TestUserRepositoryImpl.swift
//  OderRun
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

  func updateAlarm(enabled: Bool) async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    currentUser = User(
      id: currentUser.id,
      email: currentUser.email,
      name: currentUser.name,
      phone: currentUser.phone,
      createdAt: currentUser.createdAt,
      lastLoginAt: currentUser.lastLoginAt,
      alarmEnabled: enabled
    )
    return currentUser
  }

  func fetchRunnerProfile(userID: String) async throws -> RunnerProfile {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let profile = RunnerProfile.dummyByID[userID] else {
      throw RepositoryError.notFound
    }
    return profile
  }
}
