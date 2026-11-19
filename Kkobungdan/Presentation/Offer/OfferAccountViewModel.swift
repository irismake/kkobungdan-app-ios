//
//  OfferAccountViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import Foundation

/// 지원 흐름 1단계: 정산 계좌 등록. 실제 지원(offer 생성)은 다음 단계 `OfferMessageViewModel` 이 한다.
@Observable
final class OfferAccountViewModel {
  let proposalID: Int64

  let account: SettlementAccountInputModel

  init(
    proposalID: Int64,
    account: SettlementAccountInputModel
  ) {
    self.proposalID = proposalID
    self.account = account
  }

  /// 계좌 입력이 끝나야 다음 단계로 갈 수 있다.
  var canProceed: Bool {
    account.isValid
  }

  /// 정산 계좌를 등록(PUT)한다. 진행·에러 상태는 `account.register()` 가 담당한다.
  /// 성공하면 true — 호출부가 첫 인사(지원 메시지) 단계로 이동한다.
  @MainActor
  func registerAccount() async -> Bool {
    guard canProceed else {
      return false
    }
    return await account.register()
  }
}
