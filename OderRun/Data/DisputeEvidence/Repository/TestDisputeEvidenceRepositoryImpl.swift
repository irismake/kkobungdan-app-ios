//
//  TestDisputeEvidenceRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 7/2/26.
//

import Foundation

actor TestDisputeEvidenceRepositoryImpl: DisputeEvidenceRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  let store: DummyBackendStore

  init(store: DummyBackendStore) {
    self.store = store
  }

  func fetchEvidence(for query: DisputeEvidenceQuery) async throws -> DisputeEvidence {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return try await store.disputeEvidence(for: query)
  }
}
