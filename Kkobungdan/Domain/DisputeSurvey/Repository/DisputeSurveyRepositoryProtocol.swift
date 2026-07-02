//
//  DisputeSurveyRepositoryProtocol.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

protocol DisputeSurveyRepositoryProtocol: Sendable {
  /// 대상별 분쟁 설문 질문 목록. `GET /v1/dispute-survey/questions?targetType=`
  func fetchQuestions(targetType: DisputeSurveyTargetType) async throws -> [DisputeSurveyQuestion]
}
