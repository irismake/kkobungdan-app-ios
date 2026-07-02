//
//  DisputeSurveyQuestionResponseDTO.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `GET /v1/dispute-survey/questions` (분쟁 설문 질문 조회) 응답 DTO.
//  (서버: `DisputeSurveyQuestionResponse`)
//

import Foundation

struct DisputeSurveyQuestionResponseDTO: Decodable {
  let id: Int64
  let targetType: String
  let questionText: String
  let displayOrder: Int
}

extension DisputeSurveyQuestionResponseDTO {
  func toDomain() -> DisputeSurveyQuestion {
    DisputeSurveyQuestion(
      id: id,
      targetType: DisputeSurveyTargetType(rawValue: targetType) ?? .order,
      questionText: questionText,
      displayOrder: displayOrder
    )
  }
}
