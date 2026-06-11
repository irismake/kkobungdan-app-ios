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
  let proposalStatus: String
  let acceptedOfferStatus: String
  let rejectedOfferCount: Int
  let ordererID: String
  let runnerID: String
  let acceptedAt: String

  enum CodingKeys: String, CodingKey {
    case proposalID = "proposalId"
    case offerID = "offerId"
    case proposalStatus
    case acceptedOfferStatus
    case rejectedOfferCount
    case ordererID = "ordererId"
    case runnerID = "runnerId"
    case acceptedAt
  }
}

extension OfferAcceptResponseDTO {
  func toDomain() -> OfferAcceptResult {
    OfferAcceptResult(
      proposalID: proposalID,
      offerID: offerID,
      proposalStatus: ProposalStatus(rawValue: proposalStatus) ?? .matched,
      acceptedOfferStatus: OfferStatus(rawValue: acceptedOfferStatus) ?? .accepted,
      rejectedOfferCount: rejectedOfferCount,
      ordererID: ordererID,
      runnerID: runnerID,
      acceptedAt: DateFormatters.parse(acceptedAt)
    )
  }
}
