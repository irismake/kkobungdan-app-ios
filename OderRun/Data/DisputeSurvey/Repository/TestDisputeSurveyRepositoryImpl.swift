//
//  TestDisputeSurveyRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

actor TestDisputeSurveyRepositoryImpl: DisputeSurveyRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  func fetchQuestions(targetType: DisputeSurveyTargetType) async throws -> [DisputeSurveyQuestion] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let texts: [String]
    switch targetType {
    case .order:
      texts = ["주문 내용과 다른 물품을 받았어요", "물품이 누락됐어요", "기타"]
    case .runner:
      texts = ["요청자가 수령을 거부해요", "연락이 닿지 않아요", "기타"]
    }
    return texts.enumerated().map { index, text in
      DisputeSurveyQuestion(
        id: Int64(index + 1),
        targetType: targetType,
        questionText: text,
        displayOrder: index + 1
      )
    }
  }
}
