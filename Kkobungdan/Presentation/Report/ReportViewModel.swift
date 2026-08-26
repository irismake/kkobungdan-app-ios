//
//  ReportViewModel.swift
//  Kkobungdan
//
//  신고 사유 선택 화면 상태. 신고 사유 조회 + 신고 제출을 담당한다.
//

import Foundation

@Observable
final class ReportViewModel: LoadableViewModel {
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

  /// 선택한 사유가 상세 사유 작성을 요구하는지 여부. 서버가 내려주는 `requiresDetail` 을 그대로 쓴다.
  /// 상세 사유 입력은 어떤 사유를 골라도 가능하고, 이 값은 "작성 필수" 여부만 가른다.
  /// 서버도 같은 `requires_detail` 컬럼으로 검증한다 — 위반 시 400 VALIDATION_ERROR(details: detailReason).
  /// 즉 이 가드는 UX 용이고, 서버가 이중 방어다.
  var isDetailRequired: Bool {
    selectedReason?.requiresDetail ?? false
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
    await withLoading(fallback: "신고 사유를 불러오지 못했습니다.") {
      reasons = try await fetchReasonsUseCase.execute()
    }
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
