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
  // TODO: surveyQuestionID — 분쟁 설문 UI 연동 전까지 stub 값 전송
  let surveyQuestionID: Int = DisputeRequest.stubSurveyQuestionID
  let disputeReason: String

  enum CodingKeys: String, CodingKey {
    case surveyQuestionID = "surveyQuestionId"
    case disputeReason
  }

  // TODO: surveyQuestionID UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubSurveyQuestionID: Int = 0
}
