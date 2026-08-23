//
//  ReportRepository.swift
//  Kkobungdan
//

import Foundation

final class ReportRepository: ReportRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchReasons() async throws -> [ReportReason] {
    let dtos: [ProposalReportReasonQuestionResponseDTO] =
      try await client.get("/v1/proposal-report-reasons")
    return dtos
      .sorted { $0.displayOrder < $1.displayOrder }
      .map { $0.toDomain() }
  }

  func submitReport(
    proposalID: Int64,
    reasonQuestionID: Int64,
    detailReason: String?
  ) async throws {
    let _: ProposalReportResponseDTO = try await client.post(
      "/v1/proposal/\(proposalID)/reports",
      body: ProposalReportCreateRequest(
        reasonQuestionID: reasonQuestionID,
        detailReason: detailReason
      )
    )
  }
}
