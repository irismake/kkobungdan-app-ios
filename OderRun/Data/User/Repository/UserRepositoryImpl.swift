//
//  UserRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor UserRepositoryImpl: UserRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  private var currentUser: UserDetailResponseDTO = .init(
    id: DummySession.currentUserID,
    email: "me@orderrun.com",
    name: "홍길동",
    phone: "010-1234-5678",
    createdAt: "2026-01-10T10:00:00",
    lastLoginAt: "2026-04-22T09:00:00",
    alarmEnabled: true
  )

  private static let runnerProfiles: [String: RunnerProfileDTO] = [
    DummySession.currentUserID: .init(id: DummySession.currentUserID, nickname: "길동이", level: 5, grade: "B등급"),
    "user-a001": .init(id: "user-a001", nickname: "철수쓰", level: 3, grade: "C등급"),
    "user-a002": .init(id: "user-a002", nickname: "영희짱", level: 7, grade: "A등급"),
    "user-r001": .init(id: "user-r001", nickname: "민수형", level: 4, grade: "B등급"),
    "user-r002": .init(id: "user-r002", nickname: "지현님", level: 6, grade: "A등급"),
    "user-r003": .init(id: "user-r003", nickname: "준호야", level: 2, grade: "C등급")
  ]

  func fetchUserDetail() async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return currentUser.toDomain()
  }

  func updateAlarm(enabled: Bool) async throws -> User {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    currentUser = UserDetailResponseDTO(
      id: currentUser.id,
      email: currentUser.email,
      name: currentUser.name,
      phone: currentUser.phone,
      createdAt: currentUser.createdAt,
      lastLoginAt: currentUser.lastLoginAt,
      alarmEnabled: enabled
    )
    return currentUser.toDomain()
  }

  func fetchRunnerProfile(userID: String) async throws -> RunnerProfile {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let dto = Self.runnerProfiles[userID] else {
      throw RepositoryError.notFound
    }
    return dto.toDomain()
  }
}
