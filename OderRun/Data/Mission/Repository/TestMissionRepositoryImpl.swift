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

  func fetchMissionByProposal(proposalID: Int64) async throws -> Mission? {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchMission(proposalID: proposalID)
  }

  func fetchMissionByOffer(offerID: Int64) async throws -> Mission? {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return await store.fetchMission(offerID: offerID)
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.updateMissionAction(
      id: id,
      action: action,
      proofImageURL: proofImageURL,
      disputeReason: disputeReason
    )
  }
}
