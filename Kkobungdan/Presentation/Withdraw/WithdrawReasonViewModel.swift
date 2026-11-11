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
final class WithdrawReasonViewModel: LoadableViewModel {
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

  private var selectedReason: WithdrawalReason? {
    reasons.first { $0.id == selectedID }
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

  func select(id: Int64) {
    selectedID = id
  }

  @MainActor
  func load() async {
    guard reasons.isEmpty else {
      return
    }
    await withLoading(
      fallback: "탈퇴 사유를 불러오지 못했어요.",
      onFailure: { withdrawLogger.error("탈퇴 사유 조회 실패: \($0.localizedDescription)") }
    ) {
      reasons = try await fetchReasonsUseCase.execute()
    }
  }

  @MainActor
  func submit() async {
    guard canSubmit, !isSubmitting, let reason = selectedReason else {
      return
    }
    isSubmitting = true
    errorMessage = nil
    do {
      try await withdrawUseCase.execute(
        reasonQuestionID: reason.id,
        detailReason: trimmedDetail.isEmpty ? nil : trimmedDetail
      )
      tokenStorage.clear()
      didSubmit = true
    } catch let error where error.isServerError(.userNotFound) {
      withdrawLogger.info("이미 탈퇴 처리된 계정 — 완료로 간주하고 세션 정리")
      tokenStorage.clear()
      didSubmit = true
    } catch {
      errorMessage = error.userMessage(fallback: "탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.")
      withdrawLogger.error("회원 탈퇴 실패: \(error.localizedDescription)")
    }
    isSubmitting = false
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension WithdrawReasonViewModel {
  static func preview() -> WithdrawReasonViewModel {
    WithdrawReasonViewModel(
      fetchReasonsUseCase: FetchWithdrawalReasonsUseCase(userRepository: DIContainer.userRepository),
      withdrawUseCase: WithdrawUserUseCase(userRepository: DIContainer.userRepository)
    )
  }
}
