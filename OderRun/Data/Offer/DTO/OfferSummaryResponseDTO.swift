//
//  OfferSummaryResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `GET /v1/offer` (요청별 제안 목록) 응답 DTO. (서버: `OfferSummaryResponse`)
//  상세(`OfferDetailResponse`)·액션(`OfferResponse`)과 스키마가 달라 별도 타입으로 분리한다.
//

import Foundation

struct OfferSummaryResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let ordererID: String
  let ordererName: String
  let ordererLevel: Int
  let runnerID: String
  let runnerName: String
  let runnerLevel: Int
  let status: String
  let acceptedAt: String?
  let deliveryCompletedAt: String?
  let receiptConfirmedAt: String?
  let disputedAt: String?
  let resolvedAt: String?
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case ordererID = "ordererId"
    case ordererName
    case ordererLevel
    case runnerID = "runnerId"
    case runnerName
    case runnerLevel
    case status
    case acceptedAt
    case deliveryCompletedAt
    case receiptConfirmedAt
    case disputedAt
    case resolvedAt
    case createdAt
  }
}

extension OfferSummaryResponseDTO {
  func toDomain() -> Offer {
    // TODO: ordererID, ordererName, ordererLevel, acceptedAt, deliveryCompletedAt, receiptConfirmedAt, disputedAt, resolvedAt — UI 반영 시 Offer 엔티티에 추가
    Offer(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      runnerName: runnerName,
      runnerLevel: runnerLevel,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
