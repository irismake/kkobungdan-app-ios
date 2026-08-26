//
//  DisputeSurveyRepository.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

final class DisputeSurveyRepository: DisputeSurveyRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchQuestions(targetType: DisputeSurveyTargetType) async throws -> [DisputeSurveyQuestion] {
    let dtos: [DisputeSurveyQuestionResponseDTO] = try await client.get(
      "/v1/dispute-survey/questions",
      params: ["targetType": targetType.rawValue]
    )
    return dtos
      .sorted { $0.displayOrder < $1.displayOrder }
      .map { $0.toDomain() }
  }
}
