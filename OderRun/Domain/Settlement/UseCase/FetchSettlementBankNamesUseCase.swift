//
//  FetchSettlementBankNamesUseCase.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

struct FetchSettlementBankNamesUseCase {
  private let settlementRepository: SettlementRepositoryProtocol

  init(settlementRepository: SettlementRepositoryProtocol) {
    self.settlementRepository = settlementRepository
  }

  func execute() async throws -> [String] {
    try await settlementRepository.fetchBankNames()
  }
}
