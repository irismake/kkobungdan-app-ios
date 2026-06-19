//
//  ProofDeliveryRequest.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/offer/{id}/complete-delivery` 요청 바디. proofImageUrl 은 서버 optional. (서버: `ProofDeliveryRequest`)
//

import Foundation

struct ProofDeliveryRequest: Encodable {
  let proofImageUrl: String?
}
