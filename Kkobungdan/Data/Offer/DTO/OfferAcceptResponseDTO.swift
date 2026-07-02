//
//  OfferAcceptResponseDTO.swift
//  Kkobungdan
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
  let ordererName: String
  let ordererLevel: Int
  let runnerID: String
  let runnerName: String
  let runnerLevel: Int
  let acceptedAt: String

  enum CodingKeys: String, CodingKey {
    case proposalID = "proposalId"
    case offerID = "offerId"
    case proposalStatus
    case acceptedOfferStatus
    case rejectedOfferCount
    case ordererID = "ordererId"
    case ordererName
    case ordererLevel
    case runnerID = "runnerId"
    case runnerName
    case runnerLevel
    case acceptedAt
  }
}

extension OfferAcceptResponseDTO {
  func toDomain() -> OfferAcceptResult {
    // TODO: ordererName, ordererLevel, runnerName, runnerLevel — UI 반영 시 OfferAcceptResult 엔티티에 추가
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
