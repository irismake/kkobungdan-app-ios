//
//  UserWithdrawalReasonQuestionResponseDTO.swift
//  Kkobungdan
//
//  `GET /v1/user/withdrawal-reasons` (회원 탈퇴 사유 조회) 응답 DTO.
//  (서버: `UserWithdrawalReasonQuestionResponse`)
//

import Foundation

struct UserWithdrawalReasonQuestionResponseDTO: Decodable {
  let id: Int64
  let questionText: String
  let displayOrder: Int
  let requiresDetail: Bool
}

extension UserWithdrawalReasonQuestionResponseDTO {
  func toDomain() -> WithdrawalReason {
    WithdrawalReason(
      id: id,
      questionText: questionText,
      displayOrder: displayOrder,
      requiresDetail: requiresDetail
    )
  }
}
