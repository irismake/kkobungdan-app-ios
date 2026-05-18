//
//  FetchMissionByOfferUsecase.swift
//  OderRun
//
//  Created by 김가희 on 5/19/26.
//

import Foundation

struct FetchMissionByOfferUseCase {
  private let repository: MissionRepositoryProtocol

  init(repository: MissionRepositoryProtocol) {
    self.repository = repository
  }

  func execute(offerID: Int64) async throws -> Mission? {
    try await repository.fetchMissionByOffer(offerID: offerID)
  }
}
