//
//  DisputeSurveyQuestion.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `GET /v1/dispute-survey/questions` 응답에 대응되는 도메인 모델.
//  분쟁 제기 시 사용자에게 보여줄 설문 질문 한 건.
//

import Foundation

struct DisputeSurveyQuestion: Equatable, Identifiable {
  let id: Int64
  let targetType: DisputeSurveyTargetType
  let questionText: String
  let displayOrder: Int
  /// 이 사유 선택 시 상세 사유 작성이 필수인지 여부.
  let requiresDetail: Bool
}
