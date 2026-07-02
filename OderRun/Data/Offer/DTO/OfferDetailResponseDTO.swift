//
//  OfferDetailResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/19/26.
//
//  `GET /v1/offer/{id}` (제안 상세) 응답 DTO. (서버: `OfferDetailResponse`)
//  목록(`OfferSummaryResponse`)·액션(`OfferResponse`)과 스키마가 달라 별도 타입으로 분리한다.
//

import Foundation

struct OfferDetailResponseDTO: Decodable {
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
  let runnerConfirmedAt: String?
  let ordererConfirmedAt: String?
  let disputedAt: String?
  let resolvedAt: String?
  let openChatURL: String?
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
    case runnerConfirmedAt
    case ordererConfirmedAt
    case disputedAt
    case resolvedAt
    case openChatURL = "openChatUrl"
    case createdAt
  }
}

extension OfferDetailResponseDTO {
  func toDomain() -> OfferDetail {
    // TODO: ordererID, ordererName, ordererLevel, runnerLevel, acceptedAt, runnerConfirmedAt, ordererConfirmedAt, disputedAt, resolvedAt, openChatURL — UI 반영 시 OfferDetail 엔티티에 추가
    OfferDetail(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      runnerName: runnerName,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
