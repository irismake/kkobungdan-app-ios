//
//  TermsAgreementResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct TermsAgreementResponseDTO: Decodable {
  let userID: String
  let termsOfService: Bool
  let privacyPolicy: Bool
  let paymentRefundPolicy: Bool
  let agreedAt: String
}

extension TermsAgreementResponseDTO {
  func toDomain() -> TermsAgreement {
    // TODO: userID — UI 반영 시 엔티티에 추가
    TermsAgreement(
      termsOfService: termsOfService,
      privacyPolicy: privacyPolicy,
      paymentRefundPolicy: paymentRefundPolicy,
      agreedAt: DateFormatters.parse(agreedAt)
    )
  }
}
