//
//  FetchMyOffersUseCase.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct FetchMyOffersUseCase {
  private let repository: OfferRepositoryProtocol

  init(repository: OfferRepositoryProtocol) {
    self.repository = repository
  }

  func execute(status: OfferStatus? = nil, page: Int = 0, size: Int = 20) async throws -> [Offer] {
    try await repository.fetchMyOffers(status: status, page: page, size: size)
  }
}
