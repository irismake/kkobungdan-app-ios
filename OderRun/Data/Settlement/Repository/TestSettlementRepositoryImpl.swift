//
//  TestSettlementRepositoryImpl.swift
//  OderRun
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

  func saveAccount(
    bankCode: String,
    bankName: String,
    accountNumber: String,
    accountHolder: String
  ) async throws -> SettlementAccount {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let masked = Self.mask(accountNumber)
    let saved = SettlementAccount(
      bankCode: bankCode,
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
