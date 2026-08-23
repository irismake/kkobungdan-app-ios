//
//  OfferResponseDTO.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct OfferResponseDTO: Decodable {
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
    case createdAt
  }
}

extension OfferResponseDTO {
  func toDomain() -> Offer {
    // TODO: ordererID, ordererName, ordererLevel, acceptedAt, runnerConfirmedAt, ordererConfirmedAt, disputedAt, resolvedAt — UI 반영 시 Offer 엔티티에 추가
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

  /// `GET /v1/offer/own` (내 웨이팅 기록) 용 매핑. 같은 `OfferResponse` 스키마라 DTO 를 공유한다.
  func toDomain() -> MyOffer {
    // TODO: ordererID, ordererName, ordererLevel, runnerName, runnerLevel, acceptedAt,
    //       runnerConfirmedAt, ordererConfirmedAt, disputedAt, resolvedAt — UI 반영 시 MyOffer 엔티티에 추가
    MyOffer(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
