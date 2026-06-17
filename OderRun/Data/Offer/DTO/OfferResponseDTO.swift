//
//  OfferResponseDTO.swift
//  OderRun
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
  let deliveryCompletedAt: String?
  let receiptConfirmedAt: String?
  let disputedAt: String?
  let refundedAt: String?
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
    case refundedAt
    case createdAt
  }
}

extension OfferResponseDTO {
  func toDomain() -> Offer {
    // TODO: ordererID, ordererName, ordererLevel, acceptedAt, deliveryCompletedAt, receiptConfirmedAt, disputedAt, refundedAt — UI 반영 시 Offer 엔티티에 추가
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
