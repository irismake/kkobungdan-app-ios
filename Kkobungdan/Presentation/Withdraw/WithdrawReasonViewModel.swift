//
//  WithdrawReasonViewModel.swift
//  Kkobungdan
//
//  회원 탈퇴 사유 선택 화면 상태. 사유 라디오 선택 + 상세 사유 작성 후 탈퇴를 신청한다.
//  임무 중단·신고와 동일한 "사유 설문" 표현(`ReasonSurveyLayout`)을 공유한다.
//

import Foundation
import OSLog

private let withdrawLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Withdraw")

@Observable
final class WithdrawReasonViewModel {
  var reasons: [WithdrawalReason] = []
  var selectedID: Int64?
  var detail: String = ""
  var isLoading: Bool = false
  var isSubmitting: Bool = false
  var didSubmit: Bool = false
  var errorMessage: String?

  static let detailMaxLength = 500

  private let fetchReasonsUseCase: FetchWithdrawalReasonsUseCase
  private let withdrawUseCase: WithdrawUserUseCase
  private let tokenStorage: TokenStorage

  init(
    fetchReasonsUseCase: FetchWithdrawalReasonsUseCase,
    withdrawUseCase: WithdrawUserUseCase,
    tokenStorage: TokenStorage = .shared
  ) {
    self.fetchReasonsUseCase = fetchReasonsUseCase
    self.withdrawUseCase = withdrawUseCase
    self.tokenStorage = tokenStorage
  }

  static func preview() -> WithdrawReasonViewModel {
    WithdrawReasonViewModel(
      fetchReasonsUseCase: FetchWithdrawalReasonsUseCase(userRepository: DIContainer.userRepository),
      withdrawUseCase: WithdrawUserUseCase(userRepository: DIContainer.userRepository)
    )
  }

  private var selectedReason: WithdrawalReason? {
    reasons.first { $0.id == selectedID }
  }

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

  func select(id: Int64) {
    selectedID = id
    if !isDetailRequired {
      detail = ""
    }
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
      errorMessage = "탈퇴 사유를 불러오지 못했어요."
      withdrawLogger.error("탈퇴 사유 조회 실패: \(error.localizedDescription)")
    }
    isLoading = false
  }

  @MainActor
  func submit() async {
    guard canSubmit, !isSubmitting else {
      return
    }
    isSubmitting = true
    errorMessage = nil
    do {
      try await withdrawUseCase.execute(
        reasonQuestionID: selectedID,
        // 상세 사유는 필수 사유(기타 등) 선택 시에만 전송.
        detailReason: isDetailRequired && !trimmedDetail.isEmpty ? trimmedDetail : nil
      )
      tokenStorage.clear()
      didSubmit = true
    } catch {
      errorMessage = error.userMessage(fallback: "탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.")
      withdrawLogger.error("회원 탈퇴 실패: \(error.localizedDescription)")
    }
    isSubmitting = false
  }
}
