//
//  ProposalReportCreateRequest.swift
//  OderRun
//
//  `POST /v1/proposal/{proposal_id}/reports` 요청 바디. (서버: `ProposalReportCreateRequest`)
//

import Foundation

struct ProposalReportCreateRequest: Encodable {
  let reasonQuestionID: Int64
  let detailReason: String?

  enum CodingKeys: String, CodingKey {
    case reasonQuestionID = "reasonQuestionId"
    case detailReason
  }
}
