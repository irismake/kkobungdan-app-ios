//
//  FetchReportReasonsUseCase.swift
//  Kkobungdan
//

import Foundation

struct FetchReportReasonsUseCase {
  private let repository: ReportRepositoryProtocol

  init(repository: ReportRepositoryProtocol) {
    self.repository = repository
  }

  func execute() async throws -> [ReportReason] {
    try await repository.fetchReasons()
  }
}
