//
//  DisputeRequest.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/offer/{id}/dispute` · `/v1/proposal/{id}/dispute` 요청 바디. (서버: `ProofDisputeRequest`)
//  offer·proposal 분쟁 엔드포인트가 동일 스키마라 하나를 공유한다.
//

import Foundation

struct DisputeRequest: Encodable {
  let surveyQuestionID: Int64
  let disputeReason: String

  enum CodingKeys: String, CodingKey {
    case surveyQuestionID = "surveyQuestionId"
    case disputeReason
  }
}
