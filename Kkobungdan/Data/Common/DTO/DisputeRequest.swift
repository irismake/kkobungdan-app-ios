//
//  DisputeRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/offer/{id}/dispute` · `/v1/proposal/{id}/dispute` 요청 바디. (서버: `DisputeRequest`)
//  offer·proposal 분쟁 엔드포인트가 동일 스키마라 하나를 공유한다.
//

import Foundation

struct DisputeRequest: Encodable {
  let reasonQuestionID: Int64
  let detailReason: String?

  enum CodingKeys: String, CodingKey {
    case reasonQuestionID = "reasonQuestionId"
    case detailReason
  }
}
