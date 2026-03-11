//
//  ProposalRequestViewModel.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

@Observable
final class ProposalRequestViewModel {
  var title: String = ""
  var content: String = ""
  var deadline: String = ""
  var errandFee: String = ""
  var isLoading: Bool = false
  var errorMessage: String?
  var isCreated: Bool = false

  private let createProposalUseCase: CreateProposalUseCase

  init(createProposalUseCase: CreateProposalUseCase) {
    self.createProposalUseCase = createProposalUseCase
  }

  @MainActor
  func createProposal() async {
    guard !title.isEmpty, !content.isEmpty, !deadline.isEmpty, !errandFee.isEmpty else {
      errorMessage = "제목, 내용, 마감 시간, 심부름비를 모두 입력해주세요."
      return
    }

    isLoading = true
    errorMessage = nil

    do {
      _ = try await createProposalUseCase.execute(
        title: title,
        content: content,
        deadline: deadline,
        errandFee: errandFee
      )
      isCreated = true
    } catch {
      errorMessage = "요청 생성에 실패했습니다. 다시 시도해주세요."
    }

    isLoading = false
  }

  func clearError() {
    errorMessage = nil
  }
}
