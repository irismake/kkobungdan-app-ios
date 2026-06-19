//
//  TermsAgreementRequest.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/terms` (약관 동의) 요청 바디. (서버: `TermsAgreementRequest`)
//

import Foundation

struct TermsAgreementRequest: Encodable {
  let termsOfService: Bool
  let privacyPolicy: Bool
  let paymentRefundPolicy: Bool
}
