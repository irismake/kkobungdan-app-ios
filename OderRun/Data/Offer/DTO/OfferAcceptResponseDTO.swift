//
//  OfferAcceptResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  `POST /v1/offer/{offerId}/accept` 응답 DTO.
//

import Foundation

struct OfferAcceptResponseDTO: Decodable {
  let proposalID: Int64
  let offerID: Int64
  let missionID: Int64
  let proposalStatus: String
  let acceptedOfferStatus: String
  let rejectedOfferCount: Int
  let missionStatus: String
  let ordererID: String
  let runnerID: String
  let runFee: Int
  let itemPrice: Int
  let totalAmount: Int
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case proposalID = "proposalId"
    case offerID = "offerId"
    case missionID = "missionId"
    case proposalStatus
    case acceptedOfferStatus
    case rejectedOfferCount
    case missionStatus
    case ordererID = "ordererId"
    case runnerID = "runnerId"
    case runFee
    case itemPrice
    case totalAmount
    case createdAt
  }
}

extension OfferAcceptResponseDTO {
  func toDomain() -> OfferAcceptResult {
    OfferAcceptResult(
      proposalID: proposalID,
      offerID: offerID,
      missionID: missionID,
      proposalStatus: ProposalStatus(rawValue: proposalStatus) ?? .matched,
      acceptedOfferStatus: OfferStatus(rawValue: acceptedOfferStatus) ?? .accepted,
      rejectedOfferCount: rejectedOfferCount,
      missionStatus: MissionStatus(rawValue: missionStatus) ?? .created,
      ordererID: ordererID,
      runnerID: runnerID,
      runFee: runFee,
      itemPrice: itemPrice,
      totalAmount: totalAmount,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
