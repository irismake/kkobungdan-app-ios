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
  let runnerID: String
  let status: String
  let createdAt: String
}

extension OfferResponseDTO {
  func toDomain() -> Offer {
    Offer(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
