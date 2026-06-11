//
//  SettlementAccount.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct SettlementAccount: Equatable {
  let bankCode: String
  let bankName: String
  let maskedAccountNumber: String
  let accountHolder: String
  let updatedAt: Date
}
