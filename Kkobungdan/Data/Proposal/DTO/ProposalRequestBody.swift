//
//  ProposalRequestBody.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/proposal` (심부름 등록) · `PUT /v1/proposal/{id}` (심부름 수정) 요청 바디.
//  생성·수정 엔드포인트가 동일 스키마라 하나를 공유한다. (서버: `ProposalRequest`)
//

import Foundation

struct ProposalRequestBody: Encodable {
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
}
