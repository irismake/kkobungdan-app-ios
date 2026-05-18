//
//  MissionRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol MissionRepositoryProtocol: Sendable {
  /// 내 미션 목록 조회. MissionDetailViewModel 처럼 mission 상태(CREATED/IN_PROGRESS/…)가
  /// 필요한 화면에서 사용한다. 활동 탭(proposal/own, offer/own)과는 다른 경로.
  func fetchMyMissions(
    role: MissionRole,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission]
  func createMission(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> Mission
  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission
}
