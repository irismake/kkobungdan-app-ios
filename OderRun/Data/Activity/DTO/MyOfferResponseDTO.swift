//
//  MyOfferResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  /v1/offer/own 응답 항목 DTO.
//

import Foundation

struct MyOfferResponseDTO: Decodable {
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

extension MyOfferResponseDTO {
  func toDomain() -> MyOffer {
    MyOffer(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
