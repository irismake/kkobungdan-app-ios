//
//  ReportViewModel.swift
//  Kkobungdan
//
//  신고 사유 선택 화면 상태. 신고 사유 조회 + 신고 제출을 담당한다.
//

import Foundation

@Observable
final class ReportViewModel {
  /// 신고 대상 의뢰 ID.
  let proposalID: Int64

  private let fetchReasonsUseCase: FetchReportReasonsUseCase
  private let submitReportUseCase: SubmitProposalReportUseCase

  var reasons: [ReportReason] = []
  var selectedReasonID: Int64?
  var detail: String = ""
  var isLoading: Bool = false
  var isSubmitting: Bool = false
  var didSubmit: Bool = false
  var errorMessage: String?

  static let detailMaxLength = 500

  init(
    proposalID: Int64,
    fetchReasonsUseCase: FetchReportReasonsUseCase,
    submitReportUseCase: SubmitProposalReportUseCase
  ) {
    self.proposalID = proposalID
    self.fetchReasonsUseCase = fetchReasonsUseCase
    self.submitReportUseCase = submitReportUseCase
  }

  private var selectedReason: ReportReason? {
    reasons.first { $0.id == selectedReasonID }
  }

  /// 선택한 사유가 상세 사유 작성을 요구하는지 여부.
  /// 서버 스키마에 별도 플래그가 없어 "기타" 텍스트로 판별한다.
  /// TODO: 서버가 필수 여부 플래그를 제공하면 그 값으로 교체한다.
  /// 상세 사유 입력은 어떤 사유를 골라도 가능하고, 이 값은 "작성 필수" 여부만 가른다.
  var isDetailRequired: Bool {
    selectedReason?.questionText.contains("기타") ?? false
  }

  private var trimmedDetail: String {
    detail.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// 제출 가능 여부 — 사유를 선택해야 하고, 기타는 상세 사유 작성이 필수다.
  var canSubmit: Bool {
    guard selectedReason != nil else {
      return false
    }
    if isDetailRequired {
      return !trimmedDetail.isEmpty
    }
    return true
  }

  @MainActor
  func load() async {
    guard reasons.isEmpty else {
      return
    }
    isLoading = true
    errorMessage = nil
    do {
      reasons = try await fetchReasonsUseCase.execute()
    } catch {
      errorMessage = error.userMessage(fallback: "신고 사유를 불러오지 못했습니다.")
    }
    isLoading = false
  }

  func select(_ reason: ReportReason) {
    selectedReasonID = reason.id
  }

  @MainActor
  func submit() async {
    guard canSubmit, !isSubmitting, let reasonID = selectedReasonID else {
      return
    }
    isSubmitting = true
    errorMessage = nil
    do {
      try await submitReportUseCase.execute(
        proposalID: proposalID,
        reasonQuestionID: reasonID,
        // 서버 detailReason 은 optional — 작성한 경우에만 보내고, 비었으면 키를 생략한다.
        detailReason: trimmedDetail.isEmpty ? nil : trimmedDetail
      )
      didSubmit = true
    } catch {
      errorMessage = error.userMessage(fallback: "신고 접수에 실패했습니다. 잠시 후 다시 시도해 주세요.")
    }
    isSubmitting = false
  }
}
