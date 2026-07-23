//
//  WithdrawReasonViewModel.swift
//  Kkobungdan
//
//  회원 탈퇴 사유 선택 화면 상태. 사유 라디오 선택 + 상세 사유 작성 후 탈퇴를 신청한다.
//  임무 중단·신고와 동일한 "사유 설문" 표현(`ReasonSurveyLayout`)을 공유한다.
//

import Foundation

@Observable
final class WithdrawReasonViewModel {
  struct Reason: Identifiable {
    let id: Int64
    let text: String
  }

  // TODO: 탈퇴 사유는 서버 연동 전까지 하드코딩. UseCase 연결 시 load()에서 fetch 로 교체.
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

  static let detailMaxLength = 500

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
    // TODO: 탈퇴 API 연동 (presentation only). 성공 시 didSubmit = true 로 완료 처리.
  }
}
