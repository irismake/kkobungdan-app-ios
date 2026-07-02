//
//  SettlementRepositoryProtocol.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

protocol SettlementRepositoryProtocol: Sendable {
  /// 계좌 미등록 시 `nil` 을 반환한다.
  func fetchAccount() async throws -> SettlementAccount?
  func fetchBankNames() async throws -> [String]
  func saveAccount(
    bankName: String,
    accountNumber: String,
    accountHolder: String
  ) async throws -> SettlementAccount
}
