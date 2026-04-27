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
  var onSelectApplicant: (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in }

  init(
    viewModel: ApplicantListViewModel,
    onBack: @escaping () -> Void = {},
    onSelectApplicant: @escaping (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in }
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
            Text(errorMessage)
              .textStyle(.body3)
              .foregroundColor(Color.rose500)
          } else {
            ForEach(viewModel.entries) { entry in
              applicantEntryCard(entry: entry)
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
    .refreshable {
      await viewModel.load()
    }
  }

  private func applicantEntryCard(entry: ApplicantListEntry) -> some View {
    VStack(spacing: 8) {
      ApplicantCard(
        nickname: entry.profile.nickname,
        level: entry.profile.level,
        grade: entry.profile.grade,
        appliedAt: ProposalDisplay.appliedAtString(entry.offer.createdAt),
        onSelect: {
          onSelectApplicant(viewModel.proposalID, entry.offer.id)
        }
      )

      Button {
        Task { await viewModel.rejectOffer(offerID: entry.offer.id) }
      } label: {
        Text(viewModel.isRejecting ? "처리 중..." : "거절")
          .textStyle(.body2)
          .foregroundColor(Color.rose500)
          .frame(maxWidth: .infinity)
          .frame(height: 36)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 8))
          .overlay(
            RoundedRectangle(cornerRadius: 8)
              .stroke(Color.rose200, lineWidth: 1)
          )
      }
      .buttonStyle(.plain)
      .disabled(viewModel.isRejecting)
    }
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(viewModel.proposal?.title ?? "")
        .textStyle(.body2)
        .kerning(-0.15)
        .foregroundColor(Color.gray600)

      HStack(spacing: 0) {
        Text("\(viewModel.entries.count)명")
          .textStyle(.heading3, weight: .bold)
          .foregroundColor(Color.indigo500)

        Text("이 웨이팅을 지원했습니다")
          .textStyle(.heading3)
          .foregroundColor(Color.gray700)
      }
    }
  }
}
