//
//  ReportView.swift
//  Kkobungdan
//
//  신고 사유 선택 화면. 사유 라디오 선택 + 상세 사유 작성 후 신고를 제출한다.
//

import SwiftUI

struct ReportView: View {
  @State private var viewModel: ReportViewModel
  var onClose: () -> Void = {}
  var onSubmitted: () -> Void = {}

  init(
    viewModel: ReportViewModel,
    onClose: @escaping () -> Void = {},
    onSubmitted: @escaping () -> Void = {}
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onClose = onClose
    self.onSubmitted = onSubmitted
  }

  var body: some View {
    ReasonSurveyLayout(
      title: "어떤 점이 문제였나요?",
      subtitle: "운영팀이 내용을 확인할 수 있도록 신고 사유를 선택해 주세요.",
      submitTitle: "신고하기",
      submittingTitle: "신고 중...",
      options: viewModel.reasons.map { .init(id: $0.id, text: $0.questionText) },
      selectedID: viewModel.selectedReasonID,
      detail: $viewModel.detail,
      detailMaxLength: ReportViewModel.detailMaxLength,
      isDetailRequired: viewModel.isDetailRequired,
      isSubmitting: viewModel.isSubmitting,
      canSubmit: viewModel.canSubmit,
      onClose: onClose,
      onSelect: { id in
        if let reason = viewModel.reasons.first(where: { $0.id == id }) {
          viewModel.select(reason)
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
    .errorToast($viewModel.errorMessage)
  }
}

#Preview {
  ReportView(
    viewModel: ReportViewModel(
      proposalID: 1,
      fetchReasonsUseCase: FetchReportReasonsUseCase(repository: TestReportRepositoryImpl()),
      submitReportUseCase: SubmitProposalReportUseCase(repository: TestReportRepositoryImpl())
    )
  )
}
