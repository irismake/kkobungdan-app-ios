//
//  SettlementAccountResponseDTO.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct SettlementAccountResponseDTO: Decodable {
  let bankName: String
  let maskedAccountNumber: String
  let accountHolder: String
  let updatedAt: String
}

extension SettlementAccountResponseDTO {
  func toDomain() -> SettlementAccount {
    SettlementAccount(
      bankName: bankName,
      maskedAccountNumber: maskedAccountNumber,
      accountHolder: accountHolder,
      updatedAt: DateFormatters.parse(updatedAt)
    )
  }
}
