//
//  TestSettlementRepositoryImpl.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

actor TestSettlementRepositoryImpl: SettlementRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 600_000_000

  private var account: SettlementAccount?

  func fetchAccount() async throws -> SettlementAccount? {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return account
  }

  func fetchBankNames() async throws -> [String] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return ["국민은행", "신한은행", "우리은행", "하나은행", "카카오뱅크", "토스뱅크"]
  }

  func saveAccount(
    bankName: String,
    accountNumber: String,
    accountHolder: String
  ) async throws -> SettlementAccount {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let masked = Self.mask(accountNumber)
    let saved = SettlementAccount(
      bankName: bankName,
      maskedAccountNumber: masked,
      accountHolder: accountHolder,
      updatedAt: Date()
    )
    account = saved
    return saved
  }

  private static func mask(_ accountNumber: String) -> String {
    guard accountNumber.count > 4 else {
      return accountNumber
    }
    let visible = accountNumber.suffix(4)
    return String(repeating: "*", count: accountNumber.count - 4) + visible
  }
}
