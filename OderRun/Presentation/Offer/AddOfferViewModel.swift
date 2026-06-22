//
//  AddOfferViewModel.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import Foundation

@Observable
final class AddOfferViewModel {
  let proposalID: Int64

  var isOffering: Bool = false
  var errorMessage: String?
  
  let account: SettlementAccountInputModel

  private let createOfferUseCase: CreateOfferUseCase

  init(
    proposalID: Int64,
    account: SettlementAccountInputModel,
    createOfferUseCase: CreateOfferUseCase
  ) {
    self.proposalID = proposalID
    self.account = account
    self.createOfferUseCase = createOfferUseCase
  }

  /// 계좌 입력이 끝나야 지원 가능.
  var canOffer: Bool {
    account.isValid && !isOffering
  }

  /// 임무 지원하기. 정산 계좌 등록(PUT)을 먼저 마친 뒤 offer 를 생성(POST)한다.
  /// 계좌 등록은 `account.register()` 가 진행·에러 상태까지 담당한다.
  @MainActor
  func offer() async -> Bool {
    guard canOffer else {
      return false
    }
    guard await account.register() else {
      return false
    }
    isOffering = true
    errorMessage = nil
    defer { isOffering = false }
    do {
      _ = try await createOfferUseCase.execute(proposalID: proposalID)
      return true
    } catch {
      errorMessage = "지원에 실패했어요. 잠시 후 다시 시도해주세요."
      return false
    }
  }
}
