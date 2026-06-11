//
//  FetchMyOffersUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//

import Foundation

struct FetchMyOffersUseCase {
  private let repository: ActivityRepositoryProtocol

  init(repository: ActivityRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    status: [OfferStatus] = [],
    page: Int = 0,
    size: Int = 20
  ) async throws -> [MyOffer] {
    try await repository.fetchMyOffers(status: status, page: page, size: size)
  }
}
