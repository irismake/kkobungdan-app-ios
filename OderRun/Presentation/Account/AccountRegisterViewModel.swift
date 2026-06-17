//
//  AccountRegisterViewModel.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import Foundation

@Observable
final class AccountRegisterViewModel {
  let proposalID: Int64

  var accountNumber: String = ""
  var selectedBank: String?
  var isBankSheetPresented: Bool = false
  var isOffering: Bool = false
  var errorMessage: String?

  /// 임무 수행비를 받을 은행 목록.
  let banks: [String] = Bank.displayNames

  private let saveSettlementAccountUseCase: SaveSettlementAccountUseCase
  private let createOfferUseCase: CreateOfferUseCase

  init(
    proposalID: Int64,
    saveSettlementAccountUseCase: SaveSettlementAccountUseCase,
    createOfferUseCase: CreateOfferUseCase
  ) {
    self.proposalID = proposalID
    self.saveSettlementAccountUseCase = saveSettlementAccountUseCase
    self.createOfferUseCase = createOfferUseCase
  }

  /// 계좌번호 입력 + 은행 선택이 모두 끝나야 지원 가능.
  var canOffer: Bool {
    !accountNumber.isEmpty && selectedBank != nil && !isOffering
  }

  func openBankSheet() {
    isBankSheetPresented = true
  }

  func dismissBankSheet() {
    isBankSheetPresented = false
  }

  func selectBank(_ bank: String) {
    selectedBank = bank
    isBankSheetPresented = false
  }

  /// 임무 지원하기. 정산 계좌 등록(PUT)을 먼저 마친 뒤 offer 를 생성(POST)한다.
  @MainActor
  func offer() async -> Bool {
    guard canOffer else {
      return false
    }
    isOffering = true
    errorMessage = nil
    defer { isApplying = false }
    do {
      _ = try await saveSettlementAccountUseCase.execute(
        bankCode: Bank.code(for: selectedBank) ?? "",
        bankName: selectedBank,
        accountNumber: accountNumber,
        accountHolder: Self.stubAccountHolder
      )
      _ = try await createOfferUseCase.execute(proposalID: proposalID)
      isOffering = false
      return true
    } catch {
      errorMessage = "지원에 실패했어요. 잠시 후 다시 시도해주세요."
      return false
    }
    isOffering = false
    return false
  }
}

extension AccountRegisterViewModel {
  // TODO: accountHolder UI 미구현 — 예금주 입력 화면 연동 전까지 stub 값 전송.
  static let stubAccountHolder: String = "꼬봉단"
}
