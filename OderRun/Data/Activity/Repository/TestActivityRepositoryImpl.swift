//
//  TestActivityRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 5/13/26.
//
//  더미 백엔드에서 /v1/activity 는 결국 동일한 mission 저장소를 참조한다.
//  실제 백엔드 cascade(createMission → mission 적재)와 동기화를 유지하기 위해
//  TestMissionRepositoryImpl 의 missions 스냅샷을 그대로 읽어 필터링한다.
//

import Foundation

actor TestActivityRepositoryImpl: ActivityRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  func fetchMyActivities(
    role: MissionRole?,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let allActivities: [Mission]
    if let testMissionRepo = DIContainer.missionRepository as? TestMissionRepositoryImpl {
      allActivities = await testMissionRepo.snapshot()
    } else {
      allActivities = []
    }
    let resolvedRole = role ?? .orderer
    let mine = allActivities.filter {
      switch resolvedRole {
      case .orderer: return $0.ordererID == DummySession.currentUserID
      case .runner: return $0.runnerID == DummySession.currentUserID
      }
    }
    let filtered = status.map { status in mine.filter { $0.status == status } } ?? mine
    let start = page * size
    guard start < filtered.count else {
      return []
    }
    return Array(filtered[start ..< min(start + size, filtered.count)])
  }
}
