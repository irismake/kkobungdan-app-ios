//
//  ProposalReportResponseDTO.swift
//  OderRun
//
//  `POST /v1/proposal/{proposal_id}/reports` (의뢰 신고 제출) 응답 DTO.
//  (서버: `ProposalReportResponse`)
//
//  현재 클라이언트는 신고 제출 후 완료 화면으로만 이동하고 응답 필드를 사용하지 않는다.
//  서버 스키마와의 계약 검증을 위해 DTO 만 두고 별도 엔티티로는 매핑하지 않는다.
//  TODO: 신고 내역 조회 등 응답 필드를 쓰게 되면 toDomain() 으로 엔티티 매핑을 추가한다.
//

import Foundation

struct ProposalReportResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let reporterID: String
  let reasonQuestionID: Int64
  let reasonQuestionText: String
  let detailReason: String?
  let status: String
  let createdAt: String
  let reviewedAt: String?

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case reporterID = "reporterId"
    case reasonQuestionID = "reasonQuestionId"
    case reasonQuestionText
    case detailReason
    case status
    case createdAt
    case reviewedAt
  }
}
