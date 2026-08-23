//
//  UserWithdrawalRequest.swift
//  Kkobungdan
//
//  `DELETE /v1/user` (회원 탈퇴) 요청 바디. (서버: `UserWithdrawalRequest`)
//

import Foundation

struct UserWithdrawalRequest: Encodable {
  let reasonQuestionID: Int64?
  let detailReason: String?

  enum CodingKeys: String, CodingKey {
    case reasonQuestionID = "reasonQuestionId"
    case detailReason
  }
}
