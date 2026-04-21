//
//  AddProposalView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct AddProposalView: View {
  @State private var viewModel: AddProposalViewModel
  @Environment(\.dismiss) private var dismiss

  init(viewModel: AddProposalViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  private var isNextEnabled: Bool {
    !viewModel.title.isEmpty && !viewModel.content.isEmpty
  }

  var body: some View {
    VStack(spacing: 0) {
      headerSection

      scrollContent

      bottomSection
    }
    .background(Color.gray000)
    .navigationBarHidden(true)
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      AppBar(isProgress: true, onBack: {})

      VStack(alignment: .leading, spacing: 8) {
        Text("기본 정보 작성")
          .font(.custom("Pretendard-SemiBold", size: 18))
          .kerning(-0.4)
          .appLineHeight(28, fontName: "Pretendard-SemiBold", fontSize: 18)
          .foregroundColor(Color.gray900)
          .padding(.horizontal, 16)

        Text("제목과 내용을 입력해주세요")
          .font(.custom("Pretendard-Regular", size: 14))
          .kerning(-0.1)
          .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 14)
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
    BottomActionBar(title: "다음", isEnabled: isNextEnabled) {
      // TODO: 다음 단계로 이동
    }
  }
}

#Preview {
  AddProposalView(
    viewModel: AddProposalViewModel(
      createProposalUseCase: CreateProposalUseCase(
        repository: ProposalRepositoryImpl()
      )
    )
  )
}
