//
//  ReportView.swift
//  OderRun
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
    VStack(spacing: 0) {
      CloseHeader(
        title: "어떤 점이 문제였나요?",
        closePosition: .trailing,
        onClose: onClose
      )
      .padding(.top, 8)

      ScrollView {
        VStack(alignment: .leading, spacing: 24) {
          Text("운영팀이 내용을 확인할 수 있도록 신고 사유를 선택해 주세요.")
            .textStyle(.body3)
            .foregroundColor(Color.gray500)

          VStack(spacing: 12) {
            ForEach(ReportReason.allCases) { reason in
              reasonRow(reason)
            }
          }

          LabeledFieldContainer(label: "상세 사유") {
            ContentTextField(
              placeholder: "기타를 선택하신 경우 상세 사유를 꼭 작성해 주세요.",
              text: $viewModel.detail,
              maxLength: ReportViewModel.detailMaxLength
            )
          }
        }
        .padding(.horizontal, Layout.screenHorizontalPadding)
        .padding(.top, 20)
        .padding(.bottom, 12)
      }

      FillButton(
        title: viewModel.isSubmitting ? "신고 중..." : "신고하기",
        isEnabled: viewModel.canSubmit && !viewModel.isSubmitting
      ) {
        Task { await viewModel.submit() }
      }
      .padding(.horizontal, Layout.screenHorizontalPadding)
      .padding(.top, 16)
      .padding(.bottom, 20)
    }
    .background(Color.gray000)
    .onChange(of: viewModel.didSubmit) { _, didSubmit in
      if didSubmit {
        onSubmitted()
      }
    }
  }

  private func reasonRow(_ reason: ReportReason) -> some View {
    let isSelected = viewModel.selectedReason == reason
    return Button {
      viewModel.select(reason)
    } label: {
      HStack(spacing: 12) {
        radioCircle(isSelected: isSelected)

        Text(reason.displayText)
          .textStyle(.body1)
          .foregroundColor(Color.gray900)

        Spacer(minLength: 0)
      }
      .padding(.horizontal, 16)
      .frame(height: 56)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(isSelected ? Color.indigo500 : Color.gray200, lineWidth: 1)
      )
    }
    .buttonStyle(.plain)
  }

  private func radioCircle(isSelected: Bool) -> some View {
    ZStack {
      Circle()
        .stroke(isSelected ? Color.indigo500 : Color.gray300, lineWidth: 1.5)
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
  ReportView(viewModel: ReportViewModel(proposalID: 1))
}
