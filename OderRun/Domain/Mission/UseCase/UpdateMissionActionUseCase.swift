//
//  UpdateMissionActionUseCase.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct UpdateMissionActionUseCase {
  private let repository: MissionRepositoryProtocol

  init(repository: MissionRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    id: Int64,
    action: MissionAction,
    proofImageURL: String? = nil,
    disputeReason: String? = nil
  ) async throws -> Mission {
    try await repository.updateMissionAction(
      id: id,
      action: action,
      proofImageURL: proofImageURL,
      disputeReason: disputeReason
    )
  }
}
