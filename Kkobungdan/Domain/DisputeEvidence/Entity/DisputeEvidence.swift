//
//  DisputeEvidence.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/2/26.
//
//  `GET /v1/dispute-evidence` 응답에 대응되는 도메인 모델.
//  거래 당사자가 제기한 분쟁 증빙 한 건.
//

import Foundation

struct DisputeEvidence: Equatable, Identifiable {
  let id: Int64
  let proposalID: Int64
  let offerID: Int64
  /// 분쟁을 제기한 당사자(러너/오더러) ID.
  let actorID: String
  let reason: String
  let surveyQuestionID: Int64
  let createdAt: Date
}
