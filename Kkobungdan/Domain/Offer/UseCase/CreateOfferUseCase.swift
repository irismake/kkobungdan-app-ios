//
//  CreateOfferUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct CreateOfferUseCase {
  private let repository: OfferRepositoryProtocol

  init(repository: OfferRepositoryProtocol) {
    self.repository = repository
  }

  func execute(proposalID: Int64, message: String) async throws -> Offer {
    try await repository.createOffer(proposalID: proposalID, message: message)
  }
}
