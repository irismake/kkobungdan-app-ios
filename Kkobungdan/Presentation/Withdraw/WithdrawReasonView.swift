//
//  WithdrawReasonView.swift
//  Kkobungdan
//
//  회원 탈퇴 사유 선택 화면. 임무 중단·신고와 동일 디자인이라 `ReasonSurveyLayout` 을 공유한다.
//

import SwiftUI

struct WithdrawReasonView: View {
  @State private var viewModel = WithdrawReasonViewModel()
  var onClose: () -> Void = {}
  var onSubmitted: () -> Void = {}

  var body: some View {
    ReasonSurveyLayout(
      title: "탈퇴를 결심한 이유가 무엇인가요?",
      subtitle: "더 나은 서비스를 만들 수 있도록 탈퇴 사유를 알려주세요.",
      submitTitle: "탈퇴하기",
      submittingTitle: "처리 중...",
      options: viewModel.reasons.map { .init(id: $0.id, text: $0.text) },
      selectedID: viewModel.selectedID,
      detail: $viewModel.detail,
      detailMaxLength: WithdrawReasonViewModel.detailMaxLength,
      isDetailRequired: viewModel.isDetailRequired,
      isSubmitting: viewModel.isSubmitting,
      canSubmit: viewModel.canSubmit,
      onClose: onClose,
      onSelect: { viewModel.select(id: $0) },
      onSubmit: { Task { await viewModel.submit() } }
    )
    .onChange(of: viewModel.didSubmit) { _, didSubmit in
      if didSubmit {
        onSubmitted()
      }
    }
  }
}

#Preview {
  WithdrawReasonView()
}
