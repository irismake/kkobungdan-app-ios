//
//  OfferDetailResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/19/26.
//

import Foundation

struct OfferDetailResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let runnerID: String
  let status: String
  let createdAt: String
  let nickname: String
  let level: Int
  let grade: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case runnerID = "runnerId"
    case status
    case createdAt
    case nickname
    case level
    case grade
  }
}

extension OfferDetailResponseDTO {
  func toDomain() -> OfferDetail {
    OfferDetail(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt),
      nickname: nickname,
      level: level,
      grade: grade
    )
  }
}
