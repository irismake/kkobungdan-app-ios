//
//  MissionAbortView.swift
//  OderRun
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
    VStack(spacing: 0) {
      VStack(alignment: .leading, spacing: 12) {
        CloseHeader(
          title: "어떤 이유로 임무를 중단하시나요?",
          closePosition: .trailing,
          onClose: onClose
        )

        Text("임무 진행 상황에 따라 수행비가 정산될 수 있어요.")
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, Layout.screenHorizontalPadding)
      }
      .padding(.bottom, 32)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          VStack(spacing: 10) {
            ForEach(viewModel.questions) { question in
              questionRow(question)
            }
          }

          LabeledFieldContainer(label: "상세 사유") {
            ContentTextField(
              placeholder: "기타를 선택하신 경우 상세 사유를 꼭 작성해 주세요.",
              text: $viewModel.detail,
              maxLength: MissionAbortViewModel.detailMaxLength
            )
            .disabled(!viewModel.isDetailRequired)
            .opacity(viewModel.isDetailRequired ? 1 : 0.5)
          }
        }
        .padding(Layout.screenHorizontalPadding)
      }

      VStack(spacing: 0) {
        FillButton(
          title: viewModel.isSubmitting ? "처리 중..." : "임무 중단하기",
          isEnabled: viewModel.canSubmit && !viewModel.isSubmitting
        ) {
          Task { await viewModel.submit() }
        }
        .padding(.horizontal, Layout.screenHorizontalPadding)
        .padding(.top, 16)
        .padding(.bottom, 20)
      }
      .frame(maxWidth: .infinity)
      .background(Color.white)
      .overlay(alignment: .top) {
        Rectangle()
          .fill(Color.gray200)
          .frame(height: 1)
      }
    }
    .background(Color.white)
    .task {
      await viewModel.load()
    }
    .onChange(of: viewModel.didSubmit) { _, didSubmit in
      if didSubmit {
        onSubmitted()
      }
    }
  }

  private func questionRow(_ question: DisputeSurveyQuestion) -> some View {
    let isSelected = viewModel.selectedQuestionID == question.id
    return Button {
      viewModel.select(question)
    } label: {
      HStack(spacing: 14) {
        radioCircle(isSelected: isSelected)

        Text(question.questionText)
          .textStyle(.body2, weight: isSelected ? .bold : nil, kerning: -0.2)
          .foregroundColor(isSelected ? Color.indigo800 : Color.gray800)

        Spacer(minLength: 0)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(isSelected ? Color.indigo000 : Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 16))
      .overlay(
        RoundedRectangle(cornerRadius: 16)
          .stroke(isSelected ? Color.indigo400 : Color.gray200, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }

  private func radioCircle(isSelected: Bool) -> some View {
    ZStack {
      Circle()
        .stroke(isSelected ? Color.indigo500 : Color.gray300, lineWidth: 2)
        .frame(width: 20, height: 20)

      if isSelected {
        Circle()
          .fill(Color.indigo500)
          .frame(width: 10, height: 10)
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
