//
//  ProofRequests.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//
//  완료/분쟁 처리 요청 바디. offer·proposal 라이프사이클 엔드포인트가 공유한다.
//

import Foundation

/// `POST /v1/offer/{id}/complete-delivery` 요청 바디. proofImageUrl 은 서버 optional.
struct ProofDeliveryRequest: Encodable {
  let proofImageUrl: String?
}

/// `POST /v1/offer/{id}/dispute` · `/v1/proposal/{id}/dispute` 요청 바디. disputeReason 은 서버 required.
struct ProofDisputeRequest: Encodable {
  // TODO: surveyQuestionID — 분쟁 설문 UI 연동 전까지 stub 값 전송
  let surveyQuestionID: Int = ProofDisputeRequest.stubSurveyQuestionID
  let disputeReason: String

  enum CodingKeys: String, CodingKey {
    case surveyQuestionID = "surveyQuestionId"
    case disputeReason
  }
}

extension ProofDisputeRequest {
  // TODO: surveyQuestionID UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubSurveyQuestionID: Int = 0
}
