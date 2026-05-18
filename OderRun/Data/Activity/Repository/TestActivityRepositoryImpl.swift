//
//  TestActivityRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 5/13/26.
//

import Foundation

struct TestActivityRepositoryImpl: ActivityRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  let store: DummyBackendStore

  func fetchMyActivities(
    role: MissionRole?,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchMyActivities(
      userID: DummySession.currentUserID,
      role: role,
      status: status,
      page: page,
      size: size
    )
  }
}
