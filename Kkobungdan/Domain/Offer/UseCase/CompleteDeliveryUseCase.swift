//
//  CompleteDeliveryUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//
//  러너 배달 완료 처리. `POST /v1/offer/{id}/complete-delivery`
//

import Foundation

struct CompleteDeliveryUseCase {
  private let repository: OfferRepositoryProtocol

  init(repository: OfferRepositoryProtocol) {
    self.repository = repository
  }

  func execute(offerID: Int64) async throws -> Offer {
    try await repository.completeDelivery(offerID: offerID)
  }
}
