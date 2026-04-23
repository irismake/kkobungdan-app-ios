//
//  ApplicantListView.swift
//  OderRun
//
//  Created by 김가희 on 3/26/26.
//

import SwiftUI

struct ApplicantListView: View {
  @State private var viewModel: ApplicantListViewModel
  var onBack: () -> Void = {}
  var onSelectApplicant: (Int64) -> Void = { _ in }

  init(
    viewModel: ApplicantListViewModel,
    onBack: @escaping () -> Void = {},
    onSelectApplicant: @escaping (Int64) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onSelectApplicant = onSelectApplicant
  }

  var body: some View {
    VStack(spacing: 0) {
      AppBar(title: "지원 리스트", onBack: onBack)

      ScrollView {
        VStack(alignment: .leading, spacing: 12) {
          headerSection

          if viewModel.isLoading, viewModel.entries.isEmpty {
            ProgressView().padding(.top, 20)
          } else if let errorMessage = viewModel.errorMessage, viewModel.entries.isEmpty {
            Text(errorMessage).foregroundColor(Color.rose500)
          } else {
            ForEach(viewModel.entries) { entry in
              ApplicantCard(
                nickname: entry.profile.nickname,
                level: entry.profile.level,
                grade: entry.profile.grade,
                appliedAt: ProposalDisplay.appliedAtString(entry.offer.createdAt),
                onSelect: {
                  onSelectApplicant(entry.offer.id)
                }
              )
            }
          }
        }
        .padding(.horizontal, Layout.screenHorizontalPadding)
        .padding(.vertical, 12)
      }
    }
    .background(Color.gray000)
    .task {
      await viewModel.load()
    }
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(viewModel.proposal?.title ?? "")
        .font(.custom("Pretendard-Medium", size: 14))
        .kerning(-0.15)
        .appLineHeight(20, fontName: "Pretendard-Medium", fontSize: 14)
        .foregroundColor(Color.gray600)

      HStack(spacing: 0) {
        Text("\(viewModel.entries.count)명")
          .font(.custom("Pretendard-Bold", size: 18))
          .kerning(-0.4)
          .appLineHeight(28, fontName: "Pretendard-Bold", fontSize: 18)
          .foregroundColor(Color.indigo500)

        Text("이 웨이팅을 지원했습니다")
          .font(
            Font.custom("Pretendard", size: 18)
              .weight(.semibold)
          )
          .kerning(-0.4)
          .appLineHeight(28, fontName: "Pretendard-SemiBold", fontSize: 18)
          .foregroundColor(Color.gray700)
      }
    }
  }
}
