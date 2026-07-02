//
//  SettlementRepository.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

final class SettlementRepository: SettlementRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchAccount() async throws -> SettlementAccount? {
    // 미등록 시 200 + `{success, message}` (data 없음) → nil.
    let dto: SettlementAccountResponseDTO? =
      try await client.getOptional("/v1/settlement/account")
    return dto?.toDomain()
  }

  func fetchBankNames() async throws -> [String] {
    let dto: SettlementBankNamesResponseDTO =
      try await client.get("/v1/settlement/banks")
    return dto.toDomain()
  }

  func saveAccount(
    bankName: String,
    accountNumber: String,
    accountHolder: String
  ) async throws -> SettlementAccount {
    let dto: SettlementAccountResponseDTO = try await client.put(
      "/v1/settlement/account",
      body: SettlementAccountRequest(
        bankName: bankName,
        accountNumber: accountNumber,
        accountHolder: accountHolder
      )
    )
    return dto.toDomain()
  }
}
