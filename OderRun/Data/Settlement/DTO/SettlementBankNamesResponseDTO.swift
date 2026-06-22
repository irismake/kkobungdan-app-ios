//
//  SettlementBankNamesResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `GET /v1/settlement/banks` (정산 은행명 목록) 응답 DTO. (서버: `SettlementBankNamesResponse`)
//

import Foundation

struct SettlementBankNamesResponseDTO: Decodable {
  let bankNames: [String]
}

extension SettlementBankNamesResponseDTO {
  func toDomain() -> [String] {
    bankNames
  }
}
