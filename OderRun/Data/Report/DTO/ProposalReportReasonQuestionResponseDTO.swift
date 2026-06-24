//
//  ProposalReportReasonQuestionResponseDTO.swift
//  OderRun
//
//  `GET /v1/proposal-report-reasons` (의뢰 신고 사유 조회) 응답 DTO.
//  (서버: `ProposalReportReasonQuestionResponse`)
//

import Foundation

struct ProposalReportReasonQuestionResponseDTO: Decodable {
  let id: Int64
  let questionText: String
  let displayOrder: Int
}

extension ProposalReportReasonQuestionResponseDTO {
  func toDomain() -> ReportReason {
    ReportReason(
      id: id,
      questionText: questionText,
      displayOrder: displayOrder
    )
  }
}
