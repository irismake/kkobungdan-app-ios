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
  struct Reason: Identifiable {
    let id: Int64
    let text: String
  }

  // TODO: 탈퇴 사유 목록은 하드코딩. 서버 제공 스펙 확정 시 fetch use case 로 교체.
  let reasons: [Reason] = [
    Reason(id: 1, text: "원하는 임무가 많지 않았어요."),
    Reason(id: 2, text: "원하는 꼬붕(또는 행님)을 만나기 어려웠어요."),
    Reason(id: 3, text: "이용 방법이 어려웠어요."),
    Reason(id: 4, text: "앱이 자주 오류가 났어요."),
    Reason(id: 5, text: "다른 회원과 문제가 있었어요."),
    Reason(id: 6, text: "다른 서비스를 이용하려고 해요."),
    Reason(id: 7, text: "기타")
  ]

  var selectedID: Int64?
  var detail: String = ""
  var isSubmitting: Bool = false
  var didSubmit: Bool = false
  var errorMessage: String?

  static let detailMaxLength = 500

  private let withdrawUseCase: WithdrawUserUseCase
  private let tokenStorage: TokenStorage

  init(
    withdrawUseCase: WithdrawUserUseCase,
    tokenStorage: TokenStorage = .shared
  ) {
    self.withdrawUseCase = withdrawUseCase
    self.tokenStorage = tokenStorage
  }

  static func preview() -> WithdrawReasonViewModel {
    WithdrawReasonViewModel(
      withdrawUseCase: WithdrawUserUseCase(userRepository: DIContainer.userRepository)
    )
  }

  private var selectedReason: Reason? {
    reasons.first { $0.id == selectedID }
  }

  var isDetailRequired: Bool {
    selectedReason?.text.contains("기타") ?? false
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
  func submit() async {
    guard canSubmit, !isSubmitting else {
      return
    }
    isSubmitting = true
    errorMessage = nil
    do {
      // TODO: 선택한 사유(selectedReason·detail)는 서버 전송 스펙 확정 시 요청 바디로 추가.
      try await withdrawUseCase.execute()
      tokenStorage.clear()
      didSubmit = true
    } catch {
      errorMessage = "탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요."
      withdrawLogger.error("회원 탈퇴 실패: \(error.localizedDescription)")
    }
    isSubmitting = false
  }
}
