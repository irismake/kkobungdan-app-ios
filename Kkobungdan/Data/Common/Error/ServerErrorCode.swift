//
//  ServerErrorCode.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/23/26.
//

import Foundation

enum ServerErrorCode: String {
  case invalidCredentials = "INVALID_CREDENTIALS"
  case phoneVerificationSendRateLimited = "PHONE_VERIFICATION_SEND_RATE_LIMITED"
  case invalidToken = "INVALID_TOKEN"
  case userNotFound = "USER_NOT_FOUND"
}
