//
//  MissionRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol MissionRepositoryProtocol: Sendable {
  /// proposalID 로 해당 proposal 에 매칭된 미션 1건 조회. 아직 매칭되지 않아 미션이 없으면 nil.
  func fetchMissionByProposal(proposalID: Int64) async throws -> Mission?
  /// offerID 로 해당 offer 가 수락되어 생성된 미션 1건 조회. 미션이 없으면 nil.
  func fetchMissionByOffer(offerID: Int64) async throws -> Mission?
  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission
}
