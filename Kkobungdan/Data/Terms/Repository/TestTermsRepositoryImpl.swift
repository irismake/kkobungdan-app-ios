//
//  TestTermsRepositoryImpl.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

actor TestTermsRepositoryImpl: TermsRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  func agreeTerms(
    termsOfService: Bool,
    privacyPolicy: Bool,
    paymentRefundPolicy: Bool
  ) async throws -> TermsAgreement {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return TermsAgreement(
      termsOfService: termsOfService,
      privacyPolicy: privacyPolicy,
      paymentRefundPolicy: paymentRefundPolicy,
      agreedAt: Date()
    )
  }
}
