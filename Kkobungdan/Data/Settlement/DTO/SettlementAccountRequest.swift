//
//  SettlementAccountRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `PUT /v1/settlement/account` (정산 계좌 등록/수정) 요청 바디. (서버: `SettlementAccountRequest`)
//

import Foundation

struct SettlementAccountRequest: Encodable {
  let bankName: String
  let accountNumber: String
  let accountHolder: String
}
