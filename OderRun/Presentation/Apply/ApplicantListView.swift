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
  var onAccepted: () -> Void = {}
  var onSelectApplicant: (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in }

  @State private var isSelectModalPresented: Bool = false
  @State private var selectedApplicant: Offer?

  init(
    viewModel: ApplicantListViewModel,
    onBack: @escaping () -> Void = {},
    onAccepted: @escaping () -> Void = {},
    onSelectApplicant: @escaping (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onAccepted = onAccepted
    self.onSelectApplicant = onSelectApplicant
  }

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        AppBar(title: "지원 리스트", onBack: onBack)

        ScrollView {
          VStack(alignment: .leading, spacing: 12) {
            headerSection

            if viewModel.isLoading, viewModel.applicants.isEmpty {
              ProgressView().padding(.top, 20)
            } else if let errorMessage = viewModel.errorMessage, viewModel.applicants.isEmpty {
              Text(errorMessage)
                .textStyle(.body3)
                .foregroundColor(Color.rose500)
            } else {
              ForEach(viewModel.applicants) { applicant in
                applicantCard(applicant)
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

      if isSelectModalPresented, let selectedApplicant {
        ApplicantSelectModal(
          applicantName: selectedApplicant.runnerName,
          onCancel: {
            isSelectModalPresented = false
            self.selectedApplicant = nil
          },
          onConfirm: {
            Task {
              await viewModel.acceptOffer(offerID: selectedApplicant.id)
              if viewModel.didAcceptOffer {
                isSelectModalPresented = false
                self.selectedApplicant = nil
                onAccepted()
              }
            }
          }
        )
      }
    }
  }

  private func applicantCard(_ applicant: Offer) -> some View {
    VStack(spacing: 8) {
      ApplicantCard(
        nickname: applicant.runnerName,
        level: applicant.runnerLevel,
        appliedAt: ProposalDisplay.appliedAtString(applicant.createdAt),
        onSelect: {
          selectedApplicant = applicant
          isSelectModalPresented = true
        }
      )
    }
  }

  private var headerSection: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(viewModel.proposal?.title ?? "")
        .textStyle(.body2)
        .kerning(-0.15)
        .foregroundColor(Color.gray600)

      HStack(spacing: 0) {
        Text("\(viewModel.applicants.count)명")
          .textStyle(.heading3, weight: .bold)
          .foregroundColor(Color.indigo500)

        Text("이 웨이팅을 지원했습니다")
          .textStyle(.heading3)
          .foregroundColor(Color.gray700)
      }
    }
  }
}
