//
//  CreateOfferBody.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/offer` (러너 제안 등록) 요청 바디. (서버: `OfferCreate`)
//

import Foundation

struct CreateOfferBody: Encodable {
  let proposalID: Int64

  enum CodingKeys: String, CodingKey {
    case proposalID = "proposalId"
  }
}
