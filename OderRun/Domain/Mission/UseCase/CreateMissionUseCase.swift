//
//  CreateMissionUseCase.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct CreateMissionUseCase {
  private let repository: MissionRepositoryProtocol

  init(repository: MissionRepositoryProtocol) {
    self.repository = repository
  }

  func execute(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> Mission {
    try await repository.createMission(offerID: offerID, runFee: runFee, itemPrice: itemPrice)
  }
}
