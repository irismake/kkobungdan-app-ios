//
//  MissionRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol MissionRepositoryProtocol: Sendable {
  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission
}
