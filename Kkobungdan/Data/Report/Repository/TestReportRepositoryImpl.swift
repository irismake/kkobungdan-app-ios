//
//  TestReportRepositoryImpl.swift
//  Kkobungdan
//

import Foundation

actor TestReportRepositoryImpl: ReportRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  func fetchReasons() async throws -> [ReportReason] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let texts = [
      "광고 또는 스팸이에요",
      "욕설이나 혐오 표현이 있어요",
      "거짓 정보 같아요",
      "부적절한 사진이나 내용이에요",
      "기타"
    ]
    return texts.enumerated().map { index, text in
      ReportReason(
        id: Int64(index + 1),
        questionText: text,
        displayOrder: index + 1,
        requiresDetail: text == "기타"
      )
    }
  }

  func submitReport(
    proposalID _: Int64,
    reasonQuestionID _: Int64,
    detailReason _: String?
  ) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
  }
}
