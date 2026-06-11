//
//  OfferDeliveryResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct OfferDeliveryResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let runnerID: String
  let runnerName: String
  let status: String
  let acceptedAt: String
  let deliveryCompletedAt: String
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case runnerID = "runnerId"
    case runnerName
    case status
    case acceptedAt
    case deliveryCompletedAt
    case createdAt
  }
}

extension OfferDeliveryResponseDTO {
  func toDomain() -> Offer {
    // TODO: acceptedAt, deliveryCompletedAt — UI 반영 시 Offer 엔티티에 추가
    Offer(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      runnerName: runnerName,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
