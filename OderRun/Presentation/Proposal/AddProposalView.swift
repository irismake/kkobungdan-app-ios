//
//  AddProposalView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct AddProposalView: View {
  @State private var viewModel: AddProposalViewModel
  var onBack: () -> Void = {}

  init(viewModel: AddProposalViewModel, onBack: @escaping () -> Void = {}) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
  }

  private var isNextEnabled: Bool {
    !viewModel.title.isEmpty && !viewModel.content.isEmpty && !viewModel.isLoading
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      scrollContent

      bottomSection
    }
    .background(Color.gray000)
    .navigationBarHidden(true)
    .onChange(of: viewModel.didCreate) { _, didCreate in
      if didCreate {
        onBack()
      }
    }
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppBar(isProgress: true, onBack: onBack)

      VStack(alignment: .leading, spacing: 8) {
        Text("기본 정보 작성")
          .textStyle(.heading3)
          .foregroundColor(Color.gray900)
          .padding(.horizontal, 16)

        Text("제목과 내용을 입력해주세요")
          .textStyle(.body3)
          .foregroundColor(Color.gray600)
          .padding(.horizontal, 16)
      }
    }
    .padding(.bottom, 32)
    .overlay(alignment: .bottom) {
      Divider()
        .frame(height: 1)
        .foregroundColor(Color.gray200)
    }
  }

  private var scrollContent: some View {
    ScrollView {
      VStack(spacing: 24) {
        titleField
        contentField

        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
            .textStyle(.body3)
            .foregroundColor(Color.rose500)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
      .padding(16)
    }
  }

  private var titleField: some View {
    TitleTextField(
      title: "제목",
      placeholder: "예: 성수동 OO 베이커리 소금빵 웨이팅",
      text: $viewModel.title,
      maxLength: 50,
      autoFocus: true
    )
  }

  private var contentField: some View {
    ContentTextField(
      title: "내용",
      placeholder: "만남 장소를 포함한 요청 내용을 자세히 작성해주세요",
      text: $viewModel.content,
      maxLength: 500
    )
  }

  private var bottomSection: some View {
    BottomActionBar(
      title: viewModel.isLoading ? "등록 중..." : "등록하기",
      isEnabled: isNextEnabled
    ) {
      Task { await viewModel.createProposal() }
    }
  }
}

#Preview {
  AddProposalView(
    viewModel: AddProposalViewModel(
      createProposalUseCase: CreateProposalUseCase(
        repository: DIContainer.proposalRepository
      )
    )
  )
}
