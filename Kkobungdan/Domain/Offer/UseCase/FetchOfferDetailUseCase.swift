//
//  FetchOfferDetailUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/19/26.
//

import Foundation

struct FetchOfferDetailUseCase {
  private let repository: OfferRepositoryProtocol

  init(repository: OfferRepositoryProtocol) {
    self.repository = repository
  }

  func execute(offerID: Int64) async throws -> OfferDetail {
    try await repository.fetchOfferDetail(offerID: offerID)
  }
}
