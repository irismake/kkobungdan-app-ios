//
//  ReportViewModel.swift
//  OderRun
//
//  신고 사유 선택 화면 상태. 신고 제출 처리를 담당한다.
//

import Foundation

@Observable
final class ReportViewModel {
  /// 신고 대상 의뢰 ID.
  let proposalID: Int64

  var selectedReason: ReportReason?
  var detail: String = ""
  var isSubmitting: Bool = false
  var didSubmit: Bool = false
  var errorMessage: String?

  static let detailMaxLength = 500

  init(proposalID: Int64) {
    self.proposalID = proposalID
  }

  /// 제출 가능 여부 — 사유를 선택해야 하고, 기타는 상세 사유 작성이 필수다.
  var canSubmit: Bool {
    guard let reason = selectedReason else {
      return false
    }
    if reason.requiresDetail {
      return !detail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    return true
  }

  func select(_ reason: ReportReason) {
    selectedReason = reason
  }

  @MainActor
  func submit() async {
    guard canSubmit, !isSubmitting else {
      return
    }
    isSubmitting = true
    errorMessage = nil

    // TODO: 서버 신고 API 연동 시 UseCase/Repository 호출로 교체한다.
    //       (현재 서버 OpenAPI 스펙에 신고 엔드포인트가 없어 제출을 시뮬레이션한다.)
    try? await Task.sleep(nanoseconds: 600_000_000)

    isSubmitting = false
    didSubmit = true
  }
}
