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
  let runnerName: String
  let status: String
  let acceptedAt: String?
  let runnerConfirmedAt: String?
  let ordererConfirmedAt: String?
  let disputedAt: String?
  let refundedAt: String?
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case runnerID = "runnerId"
    case runnerName
    case status
    case acceptedAt
    case runnerConfirmedAt
    case ordererConfirmedAt
    case disputedAt
    case refundedAt
    case createdAt
  }
}

extension MyOfferResponseDTO {
  func toDomain() -> MyOffer {
    // TODO: runnerName, acceptedAt, runnerConfirmedAt, ordererConfirmedAt, disputedAt, refundedAt
    //       — UI 반영 시 MyOffer 엔티티에 추가.
    MyOffer(
      id: id,
      proposalID: proposalID,
      runnerID: runnerID,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
