//
//  MissionRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol MissionRepositoryProtocol: Sendable {
  func createMission(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> Mission
  func fetchMyMissions(
    role: MissionRole?,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission]
  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission
}
