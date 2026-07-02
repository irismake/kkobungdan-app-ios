//
//  AddProposalViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/28/26.
//

import Foundation

@Observable
final class AddProposalViewModel {
  var isSubmitting: Bool = false
  var errorMessage: String?

  /// 계좌 입력·확인·등록 상태. 계좌 관련 로직은 이 공용 모델이 담당한다.
  let account: SettlementAccountInputModel

  private let createProposalUseCase: CreateProposalUseCase

  init(
    createProposalUseCase: CreateProposalUseCase,
    account: SettlementAccountInputModel
  ) {
    self.createProposalUseCase = createProposalUseCase
    self.account = account
  }

  /// 등록(전송) 가능 여부. 계좌 입력이 끝났고 진행 중이 아니어야 한다.
  var canSubmit: Bool {
    account.isValid && !isSubmitting
  }

  /// 의뢰를 생성(POST)한다. 계좌 등록은 `account.register()` 가 담당한다.
  @MainActor
  func submit(
    title: String,
    content: String,
    deadline: Date,
    errandFee: Int
  ) async -> Proposal? {
    isSubmitting = true
    errorMessage = nil
    defer { isSubmitting = false }
    do {
      return try await createProposalUseCase.execute(
        title: title,
        content: content,
        deadline: DateFormatters.format(deadline),
        errandFee: errandFee
      )
    } catch {
      errorMessage = "요청 등록에 실패했어요. 다시 시도해주세요."
      return nil
    }
  }
}
