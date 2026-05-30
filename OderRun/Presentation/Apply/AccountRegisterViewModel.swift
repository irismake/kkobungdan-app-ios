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
  var isApplying: Bool = false
  var errorMessage: String?

  /// 임무 수행비를 받을 은행 목록.
  let banks: [String] = [
    "NH 농협", "카카오뱅크", "KB 국민",
    "토스뱅크", "신한", "우리",
    "IBK기업", "하나", "새마을"
  ]

  private let createOfferUseCase: CreateOfferUseCase

  init(
    proposalID: Int64,
    createOfferUseCase: CreateOfferUseCase
  ) {
    self.proposalID = proposalID
    self.createOfferUseCase = createOfferUseCase
  }

  /// 계좌번호 입력 + 은행 선택이 모두 끝나야 지원 가능.
  var canApply: Bool {
    !accountNumber.isEmpty && selectedBank != nil && !isApplying
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

  /// 임무 지원하기. 계좌 등록 후 실제 offer 를 생성한다.
  /// (더미 환경에서는 계좌번호·은행은 서버 스펙이 없어 UI 상태로만 보관한다.)
  @MainActor
  func apply() async -> Bool {
    guard canApply else {
      return false
    }
    isApplying = true
    errorMessage = nil
    do {
      _ = try await createOfferUseCase.execute(proposalID: proposalID)
      isApplying = false
      return true
    } catch {
      errorMessage = "지원에 실패했어요. 잠시 후 다시 시도해주세요."
    }
    isApplying = false
    return false
  }
}
