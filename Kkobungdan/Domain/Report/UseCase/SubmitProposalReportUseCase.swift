//
//  SubmitProposalReportUseCase.swift
//  Kkobungdan
//

import Foundation

struct SubmitProposalReportUseCase {
  private let repository: ReportRepositoryProtocol

  init(repository: ReportRepositoryProtocol) {
    self.repository = repository
  }

  func execute(
    proposalID: Int64,
    reasonQuestionID: Int64,
    detailReason: String?
  ) async throws {
    try await repository.submitReport(
      proposalID: proposalID,
      reasonQuestionID: reasonQuestionID,
      detailReason: detailReason
    )
  }
}
