//
//  ProofRequests.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//
//  완료/분쟁 처리 요청 바디. offer·proposal 라이프사이클 엔드포인트가 공유한다.
//

import Foundation

/// `POST /v1/offer/{id}/complete-delivery` 요청 바디. proofImageUrl 은 서버 optional.
struct ProofDeliveryRequest: Encodable {
  let proofImageUrl: String?
}

/// `POST /v1/offer/{id}/dispute` · `/v1/proposal/{id}/dispute` 요청 바디. disputeReason 은 서버 required.
struct ProofDisputeRequest: Encodable {
  let disputeReason: String
}
