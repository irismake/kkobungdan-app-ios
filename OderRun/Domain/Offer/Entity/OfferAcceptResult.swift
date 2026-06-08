//
//  OfferAcceptResult.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  `POST /v1/offer/{offerId}/accept` 응답에 대응되는 도메인 모델.
//

import Foundation

struct OfferAcceptResult {
  let proposalID: Int64
  let offerID: Int64
  let missionID: Int64
  let proposalStatus: ProposalStatus
  let acceptedOfferStatus: OfferStatus
  let rejectedOfferCount: Int
  let missionStatus: MissionStatus
  let ordererID: String
  let runnerID: String
  let createdAt: Date
}
