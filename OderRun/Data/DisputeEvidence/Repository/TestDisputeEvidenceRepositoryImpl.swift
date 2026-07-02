//
//  TestDisputeEvidenceRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 7/2/26.
//

import Foundation

actor TestDisputeEvidenceRepositoryImpl: DisputeEvidenceRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  func fetchEvidence(for query: DisputeEvidenceQuery) async throws -> DisputeEvidence {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let proposalID: Int64
    let offerID: Int64
    switch query {
    case let .proposal(id):
      proposalID = id
      offerID = 10
    case let .offer(id):
      proposalID = 1
      offerID = id
    }
    return DisputeEvidence(
      id: 1,
      proposalID: proposalID,
      offerID: offerID,
      actorID: "550e8400-e29b-41d4-a716-446655440001",
      reason: "배송 중 파손",
      surveyQuestionID: 3,
      createdAt: DateFormatters.parse("2026-06-01T12:00:00")
    )
  }
}
