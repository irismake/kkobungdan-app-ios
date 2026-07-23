//
//  SettlementAccountInputModel.swift
//  Kkobungdan
//
//  정산(환불) 계좌 입력 상태 + 서버 확인/등록만 담는 공용 모델.
//  계좌가 필요한 화면(offer 지원·proposal 등록)이 각자 VM 안에서 조합(compose)해 쓴다.
//

import Foundation

@Observable
final class SettlementAccountInputModel {
  /// 계좌번호 입력값. 숫자만 허용한다. 등록된 계좌가 있으면 마스킹된 번호로 채워진다.
  var accountNumber: String = "" {
    didSet {
      // 마스킹된 번호(`*` 포함)는 필터링하지 않고 그대로 표시한다.
      guard existingAccount == nil else {
        return
      }
      let digitsOnly = accountNumber.filter(\.isNumber)
      if digitsOnly != accountNumber {
        accountNumber = digitsOnly
      }
    }
  }

  /// 예금주명 입력값. 등록된 계좌가 있으면 해당 예금주명으로 채워진다.
  var accountHolder: String = ""
  /// 선택한 은행 표시명.
  var selectedBank: String?
  /// 은행 선택 시트 노출 여부.
  var isBankSheetPresented: Bool = false

  /// 서버에 이미 등록된 계좌. 없으면 `nil`.
  private(set) var existingAccount: SettlementAccount?
  private(set) var isLoading: Bool = false
  /// 계좌 등록(PUT) 진행 여부.
  private(set) var isRegistering: Bool = false
  /// 계좌 확인·등록 단계에서 발생한 에러 메시지.
  var errorMessage: String?

  /// 선택 가능한 은행 표시명 목록 (API 로드 전 빈 배열).
  private(set) var banks: [String] = []

  private let fetchAccountUseCase: FetchSettlementAccountUseCase
  private let saveAccountUseCase: SaveSettlementAccountUseCase
  private let fetchBankNamesUseCase: FetchSettlementBankNamesUseCase

  init(
    fetchAccountUseCase: FetchSettlementAccountUseCase,
    saveAccountUseCase: SaveSettlementAccountUseCase,
    fetchBankNamesUseCase: FetchSettlementBankNamesUseCase
  ) {
    self.fetchAccountUseCase = fetchAccountUseCase
    self.saveAccountUseCase = saveAccountUseCase
    self.fetchBankNamesUseCase = fetchBankNamesUseCase
  }

  /// 등록된 계좌가 있으면 입력을 막고 값만 채워 보여준다.
  var hasAccount: Bool {
    existingAccount != nil
  }

  /// 전송 가능 여부. 계좌가 이미 있거나, 새 입력(계좌번호+은행+예금주명)을 다 채웠고 진행 중이 아니어야 한다.
  var isValid: Bool {
    !isRegistering && (hasAccount || (!accountNumber.isEmpty && selectedBank != nil && !accountHolder.isEmpty))
  }

  // MARK: - Bank sheet

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

  // MARK: - Server

  /// 등록된 계좌를 확인한다. 계좌가 없으면 은행 목록도 함께 로드한다.
  @MainActor
  func loadAccount() async {
    isLoading = true
    let account = try? await fetchAccountUseCase.execute()
    existingAccount = account
    if let account {
      accountNumber = account.maskedAccountNumber
      selectedBank = account.bankName
      accountHolder = account.accountHolder
    } else {
      banks = (try? await fetchBankNamesUseCase.execute()) ?? []
    }
    isLoading = false
  }

  /// 입력한 계좌를 등록(PUT)한다. 이미 계좌가 있으면 아무것도 하지 않고 성공으로 본다.
  /// 진행·에러 상태를 직접 관리하므로 호출부는 성공 여부만 보면 된다.
  @MainActor
  func register() async -> Bool {
    guard !hasAccount else {
      return true
    }
    isRegistering = true
    errorMessage = nil
    defer { isRegistering = false }
    do {
      existingAccount = try await saveAccountUseCase.execute(
        bankName: selectedBank ?? "",
        accountNumber: accountNumber,
        accountHolder: accountHolder
      )
      return true
    } catch {
      errorMessage = error.userMessage(fallback: "계좌 등록에 실패했어요. 다시 시도해주세요.")
      return false
    }
  }
}
