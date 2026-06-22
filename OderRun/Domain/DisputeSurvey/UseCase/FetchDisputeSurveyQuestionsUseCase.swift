//
//  FetchDisputeSurveyQuestionsUseCase.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

struct FetchDisputeSurveyQuestionsUseCase {
  private let repository: DisputeSurveyRepositoryProtocol

  init(repository: DisputeSurveyRepositoryProtocol) {
    self.repository = repository
  }

  func execute(targetType: DisputeSurveyTargetType) async throws -> [DisputeSurveyQuestion] {
    try await repository.fetchQuestions(targetType: targetType)
  }
}
