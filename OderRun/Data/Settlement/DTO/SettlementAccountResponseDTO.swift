//
//  SettlementAccountResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct SettlementAccountResponseDTO: Decodable {
  let bankCode: String
  let bankName: String
  let maskedAccountNumber: String
  let accountHolder: String
  let updatedAt: String
}

extension SettlementAccountResponseDTO {
  func toDomain() -> SettlementAccount {
    SettlementAccount(
      bankCode: bankCode,
      bankName: bankName,
      maskedAccountNumber: maskedAccountNumber,
      accountHolder: accountHolder,
      updatedAt: DateFormatters.parse(updatedAt)
    )
  }
}
