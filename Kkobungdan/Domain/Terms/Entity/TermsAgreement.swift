//
//  TermsAgreement.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct TermsAgreement: Equatable {
  let termsOfService: Bool
  let privacyPolicy: Bool
  let paymentRefundPolicy: Bool
  let agreedAt: Date
}
