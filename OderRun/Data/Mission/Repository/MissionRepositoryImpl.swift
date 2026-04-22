//
//  MissionRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

final class MissionRepositoryImpl: MissionRepositoryProtocol, Sendable {
  func createMission(offerID _: Int64, runFee _: Int, itemPrice _: Int) async throws -> Mission {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }

  func fetchMyMissions(
    role _: MissionRole?,
    status _: MissionStatus?,
    page _: Int,
    size _: Int
  ) async throws -> [Mission] {
    // TODO: Step 4 에서 seed 채움
    []
  }

  func updateMissionAction(
    id _: Int64,
    action _: MissionAction,
    proofImageURL _: String?,
    disputeReason _: String?
  ) async throws -> Mission {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }
}
