//
//  AddProposalViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/28/26.
//

import Foundation

@Observable
final class AddProposalViewModel {
  var isSubmitting: Bool = false
  var errorMessage: String?

  private let createProposalUseCase: CreateProposalUseCase

  init(createProposalUseCase: CreateProposalUseCase) {
    self.createProposalUseCase = createProposalUseCase
  }

  @MainActor
  func submit(
    title: String,
    content: String,
    deadline: Date,
    errandFee: Int
  ) async -> ProposalDetail? {
    guard !isSubmitting else {
      return nil
    }
    isSubmitting = true
    errorMessage = nil
    do {
      let detail = try await createProposalUseCase.execute(
        title: title,
        content: content,
        deadline: DateFormatters.format(deadline),
        errandFee: errandFee
      )
      isSubmitting = false
      return detail
    } catch {
      errorMessage = "요청 등록에 실패했어요. 다시 시도해주세요."
      isSubmitting = false
      return nil
    }
  }
}
