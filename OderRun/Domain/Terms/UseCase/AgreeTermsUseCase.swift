//
//  AgreeTermsUseCase.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct AgreeTermsUseCase {
  private let termsRepository: TermsRepositoryProtocol

  init(termsRepository: TermsRepositoryProtocol) {
    self.termsRepository = termsRepository
  }

  func execute(
    termsOfService: Bool,
    privacyPolicy: Bool,
    paymentRefundPolicy: Bool
  ) async throws -> TermsAgreement {
    try await termsRepository.agreeTerms(
      termsOfService: termsOfService,
      privacyPolicy: privacyPolicy,
      paymentRefundPolicy: paymentRefundPolicy
    )
  }
}
