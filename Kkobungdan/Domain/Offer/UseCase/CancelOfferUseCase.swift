//
//  CancelOfferUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct CancelOfferUseCase {
  private let repository: OfferRepositoryProtocol

  init(repository: OfferRepositoryProtocol) {
    self.repository = repository
  }

  func execute(offerID: Int64) async throws {
    try await repository.cancelOffer(offerID: offerID)
  }
}
