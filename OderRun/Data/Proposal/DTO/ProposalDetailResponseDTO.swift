//
//  ProposalDetailResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//
//  `GET /v1/proposal/{id}` 응답 DTO.
//  목록/생성 응답(`ProposalResponseDTO`)과 필드 구성이 달라 별도 타입으로 분리한다.
//

import Foundation

struct ProposalDetailResponseDTO: Decodable {
  let id: Int64
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
  let ordererID: String
  let status: String
  let matchedAt: String?
  let deliveryReportedAt: String?
  let receivedConfirmedAt: String?
  let disputedAt: String?
  let refundedAt: String?
  /// 서버 스펙상 optional (`array | null`). 미전송 시에도 디코딩되도록 `?`.
  let offers: [ProposalOwnOfferResponseDTO]?

  enum CodingKeys: String, CodingKey {
    case id, title, content, deadline, errandFee
    case ordererID = "ordererId"
    case status, matchedAt, deliveryReportedAt, receivedConfirmedAt, disputedAt, refundedAt, offers
  }
}

/// 상세 응답에 임베드되는 offer 요약. (서버: `ProposalOwnOfferResponse`)
/// proposal 라이프사이클 응답(상세·수령확인·분쟁)이 공유한다.
struct ProposalOwnOfferResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let runnerID: String
  let status: String
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case runnerID = "runnerId"
    case status
    case createdAt
  }
}

extension ProposalDetailResponseDTO {
  func toDomain() -> Proposal {
    // TODO: ordererID, matchedAt, deliveryReportedAt, receivedConfirmedAt, disputedAt, refundedAt, offers — UI 반영 시 Proposal 엔티티에 추가
    Proposal(
      id: id,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: errandFee,
      status: ProposalStatus(rawValue: status) ?? .posted
    )
  }
}
