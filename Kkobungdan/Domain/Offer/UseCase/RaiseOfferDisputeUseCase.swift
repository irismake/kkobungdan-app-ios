//
//  RaiseOfferDisputeUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//
//  러너 분쟁 제기. `POST /v1/offer/{id}/dispute`
//

import Foundation

struct RaiseOfferDisputeUseCase {
  private let repository: OfferRepositoryProtocol

  init(repository: OfferRepositoryProtocol) {
    self.repository = repository
  }

  func execute(offerID: Int64, reasonQuestionID: Int64, detailReason: String?) async throws -> Offer {
    try await repository.raiseDispute(offerID: offerID, reasonQuestionID: reasonQuestionID, detailReason: detailReason)
  }
}
