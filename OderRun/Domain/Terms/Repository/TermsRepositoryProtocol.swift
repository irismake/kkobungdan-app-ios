//
//  TermsRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

protocol TermsRepositoryProtocol: Sendable {
  func agreeTerms(
    termsOfService: Bool,
    privacyPolicy: Bool,
    paymentRefundPolicy: Bool
  ) async throws -> TermsAgreement
}
