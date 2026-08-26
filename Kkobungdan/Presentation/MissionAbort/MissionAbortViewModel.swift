//
//  MissionAbortViewModel.swift
//  Kkobungdan
//
//  임무 중단(분쟁 제기) 화면 상태. 중단 설문 질문 조회 + 분쟁 제출을 담당한다.
//  오더러(proposal)·러너(offer) 분쟁 엔드포인트가 갈라지므로 대상별 use case 를 직접 들고 분기한다.
//

import Foundation

@Observable
final class MissionAbortViewModel: LoadableViewModel {
  /// 중단 대상. 어떤 분쟁 엔드포인트를 호출할지 + 설문 대상 타입을 가른다.
  enum Submit {
    case proposal(proposalID: Int64, useCase: RaiseProposalDisputeUseCase)
    case offer(offerID: Int64, useCase: RaiseOfferDisputeUseCase)

    var surveyTargetType: DisputeSurveyTargetType {
      switch self {
      case .proposal: .order
      case .offer: .runner
      }
    }
  }

  private let submitTarget: Submit
  private let fetchQuestionsUseCase: FetchDisputeSurveyQuestionsUseCase

  var questions: [DisputeSurveyQuestion] = []
  var selectedQuestionID: Int64?
  var detail: String = ""
  var isLoading: Bool = false
  var isSubmitting: Bool = false
  var didSubmit: Bool = false
  var errorMessage: String?

  static let detailMaxLength = 500

  init(
    submitTarget: Submit,
    fetchQuestionsUseCase: FetchDisputeSurveyQuestionsUseCase
  ) {
    self.submitTarget = submitTarget
    self.fetchQuestionsUseCase = fetchQuestionsUseCase
  }

  private var selectedQuestion: DisputeSurveyQuestion? {
    questions.first { $0.id == selectedQuestionID }
  }

  var isDetailRequired: Bool {
    selectedQuestion?.questionText.contains("기타") ?? false
  }

  private var trimmedDetail: String {
    detail.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  /// 제출 가능 여부 — 사유를 선택해야 하고, 기타는 상세 사유 작성이 필수다.
  var canSubmit: Bool {
    guard selectedQuestion != nil else {
      return false
    }
    if isDetailRequired {
      return !trimmedDetail.isEmpty
    }
    return true
  }

  @MainActor
  func load() async {
    guard questions.isEmpty else {
      return
    }
    await withLoading(fallback: "중단 사유를 불러오지 못했습니다.") {
      questions = try await fetchQuestionsUseCase.execute(targetType: submitTarget.surveyTargetType)
        .sorted { $0.displayOrder < $1.displayOrder }
    }
  }

  func select(_ question: DisputeSurveyQuestion) {
    selectedQuestionID = question.id
  }

  @MainActor
  func submit() async {
    guard canSubmit, !isSubmitting, let question = selectedQuestion else {
      return
    }
    isSubmitting = true
    errorMessage = nil
    // 서버 detailReason 은 optional — 작성한 경우에만 보내고, 비었으면 키를 생략한다.
    let detailReason = trimmedDetail.isEmpty ? nil : trimmedDetail
    do {
      switch submitTarget {
      case let .proposal(proposalID, useCase):
        _ = try await useCase.execute(
          proposalID: proposalID,
          reasonQuestionID: question.id,
          detailReason: detailReason
        )
      case let .offer(offerID, useCase):
        _ = try await useCase.execute(
          offerID: offerID,
          reasonQuestionID: question.id,
          detailReason: detailReason
        )
      }
      didSubmit = true
    } catch {
      errorMessage = error.userMessage(fallback: "임무 중단 신청에 실패했습니다. 잠시 후 다시 시도해 주세요.")
    }
    isSubmitting = false
  }
}
