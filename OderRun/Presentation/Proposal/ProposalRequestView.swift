//
//  ProposalRequestView.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import SwiftUI

struct ProposalRequestView: View {
  @State private var viewModel: ProposalRequestViewModel

  init(viewModel: ProposalRequestViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    VStack(spacing: 0) {
      Gap.v(120) // 상단 여백 (상태바 + 디자인 상단 공간)

      brandSection

      Spacer()

      socialButtonsSection
        .padding(.bottom, 12)

      bottomTermsSection
        .padding(.bottom, 24)
    }
  }

  private var brandSection: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("대신 웨이팅 요청하기")
        .odrStyle(.title1(weight: .bold, color: Color.gray800))

      Text("어디에서, 어떤 웨이팅을 맡길지와 보상을 적어주세요.")
        .odrStyle(.body3(color: Color.gray600))
    }
  }

  private var socialButtonsSection: some View {
    VStack(spacing: 16) {
      labeledTextField(
        title: "제목",
        placeholder: "예: 강남역 A카페 웨이팅 부탁",
        text: $viewModel.title
      )

      labeledTextField(
        title: "마감 시간",
        placeholder: "예: 2026-03-11T15:30:00",
        text: $viewModel.deadline
      )

      labeledTextField(
        title: "심부름비 (원)",
        placeholder: "예: 4000",
        text: $viewModel.errandFee,
        keyboard: .numberPad
      )

      VStack(alignment: .leading, spacing: 8) {
        Text("내용")
          .odrStyle(.body3(weight: .medium, color: Color.gray800))

        TextEditor(text: $viewModel.content)
          .frame(minHeight: 120)
          .padding(10)
          .background(Color.gray000)
          .clipShape(RoundedRectangle(cornerRadius: 12))
      }
    }
  }

  private func labeledTextField(
    title: String,
    placeholder: String,
    text: Binding<String>,
    keyboard: UIKeyboardType = .default
  ) -> some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .odrStyle(.body3(weight: .medium, color: Color.gray800))

      TextField(placeholder, text: text)
        .odrTextFieldStyle(.body2(color: Color.gray800))
        .keyboardType(keyboard)
        .padding(.horizontal, 12)
        .frame(height: 48)
        .background(Color.gray000)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
  }

  private var bottomTermsSection: some View {
    Button {
      Task {
        await viewModel.createProposal()
      }
    } label: {
      Group {
        if viewModel.isLoading {
          ProgressView()
            .tint(.white)
        } else {
          Text("요청 올리기")
            .odrStyle(.body1())
        }
      }
      .frame(maxWidth: .infinity)
      .frame(height: 52)
    }
    .buttonStyle(.borderedProminent)
    .tint(.indigo500)
    .disabled(viewModel.isLoading)
    .padding(.top, 8)
  }
}

#Preview {
  ScreenContainer {
    ProposalRequestView(
      viewModel: ProposalRequestViewModel(
        createProposalUseCase: CreateProposalUseCase(
          repository: ProposalRepositoryImpl()
        )
      )
    )
  }
}
