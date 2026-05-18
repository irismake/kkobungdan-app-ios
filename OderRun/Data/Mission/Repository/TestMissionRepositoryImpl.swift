//
//  TestMissionRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct TestMissionRepositoryImpl: MissionRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  let store: DummyBackendStore

  func createMission(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> Mission {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.createMission(offerID: offerID, runFee: runFee, itemPrice: itemPrice)
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason _: String?
  ) async throws -> Mission {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.updateMissionAction(id: id, action: action, proofImageURL: proofImageURL)
  }
}
