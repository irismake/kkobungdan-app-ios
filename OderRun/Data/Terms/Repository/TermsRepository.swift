//
//  TermsRepository.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

private struct TermsAgreementRequest: Encodable {
  let termsOfService: Bool
  let privacyPolicy: Bool
  let paymentRefundPolicy: Bool
}

final class TermsRepository: TermsRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func agreeTerms(
    termsOfService: Bool,
    privacyPolicy: Bool,
    paymentRefundPolicy: Bool
  ) async throws -> TermsAgreement {
    let dto: TermsAgreementResponseDTO = try await client.post(
      "/v1/terms",
      body: TermsAgreementRequest(
        termsOfService: termsOfService,
        privacyPolicy: privacyPolicy,
        paymentRefundPolicy: paymentRefundPolicy
      )
    )
    return dto.toDomain()
  }
}
