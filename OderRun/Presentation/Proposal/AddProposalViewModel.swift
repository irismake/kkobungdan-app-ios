//
//  AddProposalViewModel.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

@Observable
final class AddProposalViewModel {
  var title: String = ""
  var content: String = ""
  var deadline: String = ""
  var errandFee: String = ""
  var isLoading: Bool = false
  var errorMessage: String?
  var didCreate: Bool = false

  private let createProposalUseCase: CreateProposalUseCase

  init(createProposalUseCase: CreateProposalUseCase) {
    self.createProposalUseCase = createProposalUseCase
  }

  @MainActor
  func createProposal() async {
    guard !title.isEmpty, !content.isEmpty else {
      errorMessage = "제목과 내용을 입력해주세요."
      return
    }

    isLoading = true
    errorMessage = nil

    let resolvedDeadline = deadline.isEmpty ? Self.defaultDeadlineString() : deadline
    let resolvedFee = errandFee.isEmpty ? "5000" : errandFee

    do {
      _ = try await createProposalUseCase.execute(
        title: title,
        content: content,
        deadline: resolvedDeadline,
        errandFee: resolvedFee
      )
      didCreate = true
    } catch {
      errorMessage = "요청 생성에 실패했습니다. 다시 시도해주세요."
    }

    isLoading = false
  }

  func clearError() {
    errorMessage = nil
  }

  /// 더미 모드에서 deadline 입력 화면이 아직 wiring 되지 않았을 때 사용하는 기본값 (24시간 뒤)
  private static func defaultDeadlineString() -> String {
    DateFormatters.format(Date().addingTimeInterval(86400))
  }
}
