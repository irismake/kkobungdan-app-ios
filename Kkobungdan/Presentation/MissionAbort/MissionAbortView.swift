//
//  MissionAbortView.swift
//  Kkobungdan
//
//  임무 중단(분쟁 제기) 사유 선택 화면. 중단 사유 라디오 선택 + 상세 사유 작성 후 중단을 신청한다.
//

import SwiftUI

struct MissionAbortView: View {
  @State private var viewModel: MissionAbortViewModel
  var onClose: () -> Void = {}
  var onSubmitted: () -> Void = {}

  init(
    viewModel: MissionAbortViewModel,
    onClose: @escaping () -> Void = {},
    onSubmitted: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onClose = onClose
    self.onSubmitted = onSubmitted
  }

  var body: some View {
    ReasonSurveyLayout(
      title: "어떤 이유로 임무를 중단하시나요?",
      subtitle: "임무 진행 상황에 따라 수행비가 정산될 수 있어요.",
      submitTitle: "임무 중단하기",
      submittingTitle: "처리 중...",
      options: viewModel.questions.map { .init(id: $0.id, text: $0.questionText) },
      selectedID: viewModel.selectedQuestionID,
      detail: $viewModel.detail,
      detailMaxLength: MissionAbortViewModel.detailMaxLength,
      isDetailRequired: viewModel.isDetailRequired,
      isSubmitting: viewModel.isSubmitting,
      canSubmit: viewModel.canSubmit,
      onClose: onClose,
      onSelect: { id in
        if let question = viewModel.questions.first(where: { $0.id == id }) {
          viewModel.select(question)
        }
      },
      onSubmit: { Task { await viewModel.submit() } }
    )
    .task {
      await viewModel.load()
    }
    .onChange(of: viewModel.didSubmit) { _, didSubmit in
      if didSubmit {
        onSubmitted()
      }
    }
  }
}

#Preview {
  MissionAbortView(
    viewModel: MissionAbortViewModel(
      submitTarget: .proposal(
        proposalID: 1,
        useCase: RaiseProposalDisputeUseCase(repository: TestProposalRepositoryImpl(store: DummyBackendStore()))
      ),
      fetchQuestionsUseCase: FetchDisputeSurveyQuestionsUseCase(
        repository: TestDisputeSurveyRepositoryImpl()
      )
    )
  )
}
