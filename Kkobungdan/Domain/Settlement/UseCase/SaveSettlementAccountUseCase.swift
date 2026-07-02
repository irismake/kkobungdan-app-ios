//
//  SaveSettlementAccountUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct SaveSettlementAccountUseCase {
  private let settlementRepository: SettlementRepositoryProtocol

  init(settlementRepository: SettlementRepositoryProtocol) {
    self.settlementRepository = settlementRepository
  }

  func execute(
    bankName: String,
    accountNumber: String,
    accountHolder: String
  ) async throws -> SettlementAccount {
    try await settlementRepository.saveAccount(
      bankName: bankName,
      accountNumber: accountNumber,
      accountHolder: accountHolder
    )
  }
}
