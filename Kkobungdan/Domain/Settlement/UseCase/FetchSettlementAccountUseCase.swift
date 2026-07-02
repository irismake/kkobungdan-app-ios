//
//  FetchSettlementAccountUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct FetchSettlementAccountUseCase {
  private let settlementRepository: SettlementRepositoryProtocol

  init(settlementRepository: SettlementRepositoryProtocol) {
    self.settlementRepository = settlementRepository
  }

  func execute() async throws -> SettlementAccount? {
    try await settlementRepository.fetchAccount()
  }
}
