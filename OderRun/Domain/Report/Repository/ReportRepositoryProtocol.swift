//
//  ReportRepositoryProtocol.swift
//  OderRun
//

import Foundation

protocol ReportRepositoryProtocol: Sendable {
  /// 의뢰 신고 사유 선택지 목록. `GET /v1/proposal-report-reasons`
  func fetchReasons() async throws -> [ReportReason]

  /// 의뢰 신고 제출. `POST /v1/proposal/{proposal_id}/reports`
  func submitReport(
    proposalID: Int64,
    reasonQuestionID: Int64,
    detailReason: String?
  ) async throws
}
