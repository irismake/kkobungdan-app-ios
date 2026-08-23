//
//  WithdrawalReason.swift
//  Kkobungdan
//
//  `GET /v1/user/withdrawal-reasons` 응답에 대응되는 도메인 모델.
//  회원 탈퇴 시 사용자에게 보여줄 탈퇴 사유 선택지 한 건.
//

import Foundation

struct WithdrawalReason: Equatable, Identifiable {
  let id: Int64
  let questionText: String
  let displayOrder: Int
  /// 이 사유 선택 시 상세 사유 작성이 필수인지 여부.
  let requiresDetail: Bool
}
