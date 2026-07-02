//
//  AcceptOfferUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/18/26.
//

import Foundation

struct AcceptOfferUseCase {
  private let repository: OfferRepositoryProtocol

  init(repository: OfferRepositoryProtocol) {
    self.repository = repository
  }

  func execute(offerID: Int64) async throws -> OfferAcceptResult {
    try await repository.acceptOffer(offerID: offerID)
  }
}
