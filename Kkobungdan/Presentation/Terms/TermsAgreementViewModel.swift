//
//  TermsAgreementViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

@Observable
final class TermsAgreementViewModel {
  var isTermsAgreed: Bool = false
  var isPrivacyAgreed: Bool = false

  var isAllAgreed: Bool {
    isTermsAgreed && isPrivacyAgreed
  }

  var canProceed: Bool {
    isTermsAgreed && isPrivacyAgreed
  }

  func toggleAll() {
    let newValue = !isAllAgreed
    isTermsAgreed = newValue
    isPrivacyAgreed = newValue
  }
}
