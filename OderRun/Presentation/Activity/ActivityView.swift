//
//  ActivityView.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//

import SwiftUI

enum ActivitySegment: String, CaseIterable {
  case orderer
  case runner

  var title: String {
    switch self {
    case .orderer: return "요청"
    case .runner: return "웨이팅 기록"
    }
  }
}

enum ActivityFilter: String, CaseIterable {
  case all = "전체"
  case waiting = "대기중"
  case inProgress = "진행중"
  case completed = "완료"
  case cancelled = "취소"

  func matches(_ stage: ActivityStage) -> Bool {
    switch self {
    case .all: return true
    case .waiting: return stage == .waiting
    case .inProgress: return stage == .inProgress
    case .completed: return stage == .completed
    case .cancelled: return stage == .cancelled
    }
  }
}

struct ActivityView: View {
  @State private var viewModel: ActivityViewModel
  @State private var segment: ActivitySegment = .orderer
  @State private var filter: ActivityFilter = .all
  @State private var pendingCancelEntry: ActivityItem?

  var onSelectOrdererProposal: (Int64) -> Void = { _ in }
  var onSelectRunnerItem: (_ proposalID: Int64, _ hasMission: Bool) -> Void = { _, _ in }

  private struct SegmentAnchorPreferenceKey: PreferenceKey {
    static var defaultValue: [ActivitySegment: Anchor<CGRect>] = [:]

    static func reduce(
      value: inout [ActivitySegment: Anchor<CGRect>],
      nextValue: () -> [ActivitySegment: Anchor<CGRect>]
    ) {
      value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
  }

  init(
    viewModel: ActivityViewModel,
    onSelectOrdererProposal: @escaping (Int64) -> Void = { _ in },
    onSelectRunnerItem: @escaping (_ proposalID: Int64, _ hasMission: Bool) -> Void = { _, _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onSelectOrdererProposal = onSelectOrdererProposal
    self.onSelectRunnerItem = onSelectRunnerItem
  }

  var body: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "내 활동")

      segmentControl

      filterChips

      ScrollView {
        VStack(spacing: 12) {
          if viewModel.isLoading, filteredItems.isEmpty {
            ProgressView()
              .padding(.top, 40)
          } else if let errorMessage = viewModel.errorMessage, filteredItems.isEmpty {
            Text(errorMessage)
              .textStyle(.body3)
              .foregroundColor(Color.rose500)
              .padding(.top, 40)
          } else if filteredItems.isEmpty {
            Text(emptyMessage)
              .textStyle(.body3)
              .foregroundColor(Color.gray500)
              .padding(.top, 40)
          } else {
            ForEach(filteredItems) { item in
              VStack(spacing: 8) {
                activityCard(for: item)
                  .contentShape(Rectangle())
                  .onTapGesture {
                    handleSelection(item)
                  }

                if canCancelOffer(item) {
                  cancelOfferButton(for: item)
                }
              }
            }
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
      }
      .background(Color.gray000)
    }
    .task {
      await viewModel.load()
    }
    .refreshable {
      await viewModel.load()
    }
    .alert(
      "지원을 취소할까요?",
      isPresented: Binding(
        get: { pendingCancelEntry != nil },
        set: { if !$0 {
          pendingCancelEntry = nil
        } }
      ),
      presenting: pendingCancelEntry
    ) { entry in
      Button("취소", role: .cancel) {
        pendingCancelEntry = nil
      }
      Button("지원 취소", role: .destructive) {
        guard let offerID = entry.offer?.id else {
          return
        }
        Task { await viewModel.cancelMyOffer(offerID: offerID) }
      }
    } message: { entry in
      Text(entry.proposal.title)
    }
  }

  private func canCancelOffer(_ item: ActivityItem) -> Bool {
    segment == .runner && item.offer?.status == .waiting && item.mission == nil
  }

  private func cancelOfferButton(for item: ActivityItem) -> some View {
    let isCancelling = viewModel.isCancellingOfferID == item.offer?.id
    return Button {
      pendingCancelEntry = item
    } label: {
      Text(isCancelling ? "취소 중..." : "지원 취소")
        .textStyle(.body3, weight: .bold)
        .foregroundColor(Color.rose500)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
          RoundedRectangle(cornerRadius: 8)
            .stroke(Color.rose200, lineWidth: 1)
        )
    }
    .buttonStyle(.plain)
    .disabled(isCancelling)
  }

  private var currentItems: [ActivityItem] {
    switch segment {
    case .orderer: return viewModel.ordererItems
    case .runner: return viewModel.runnerItems
    }
  }

  private var filteredItems: [ActivityItem] {
    currentItems.filter { filter.matches($0.stage) }
  }

  private var emptyMessage: String {
    switch segment {
    case .orderer: return "아직 등록한 의뢰가 없어요."
    case .runner: return "아직 지원한 의뢰가 없어요."
    }
  }

  private var segmentControl: some View {
    HStack(spacing: 0) {
      ForEach(ActivitySegment.allCases, id: \.self) { item in
        let isSelected = item == segment
        Button {
          segment = item
          filter = .all
        } label: {
          VStack(spacing: 0) {
            Text(item.title)
              .textStyle(.heading5)
              .foregroundColor(isSelected ? Color.gray900 : Color.gray500)
              .padding(8)
          }
          .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
        .anchorPreference(key: SegmentAnchorPreferenceKey.self, value: .bounds) { anchor in
          [item: anchor]
        }
      }
    }
    .padding(.horizontal, 16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
    .overlayPreferenceValue(SegmentAnchorPreferenceKey.self) { anchors in
      GeometryReader { proxy in
        if let anchor = anchors[segment] {
          let frame = proxy[anchor]
          Rectangle()
            .fill(Color.gray900)
            .frame(width: frame.width, height: 2)
            .position(x: frame.midX, y: proxy.size.height - 1)
        }
      }
    }
    .background(Color.gray000)
  }

  private var filterChips: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(ActivityFilter.allCases, id: \.self) { item in
          let isSelected = item == filter
          Button {
            filter = item
          } label: {
            Text(item.rawValue)
              .textStyle(.title2, kerning: -0.1)
              .foregroundColor(isSelected ? Color.indigo000 : Color.gray800)
              .padding(.horizontal, 16)
              .padding(.vertical, 6)
              .background(isSelected ? Color.indigo500 : Color.gray200)
              .clipShape(Capsule())
          }
          .buttonStyle(.plain)
        }
      }
      .padding(.horizontal, 16)
      .padding(.top, 16)
      .padding(.bottom, 4)
    }
    .background(Color.gray000)
  }

  private func activityCard(for item: ActivityItem) -> some View {
    let proposal = item.proposal
    return ProposalCard(
      title: proposal.title,
      description: proposal.content,
      date: ProposalDisplay.dateString(proposal.deadline),
      time: ProposalDisplay.timeString(proposal.deadline),
      fee: ProposalDisplay.feeString(proposal.errandFee),
      badges: badges(for: item)
    )
  }

  private func badges(for item: ActivityItem) -> [BadgeItem] {
    ProposalDisplay.badges(
      proposal: item.proposal,
      mission: item.mission,
      myOfferStatus: item.offer?.status
    )
  }

  private func handleSelection(_ item: ActivityItem) {
    switch segment {
    case .orderer:
      onSelectOrdererProposal(item.proposal.id)
    case .runner:
      onSelectRunnerItem(item.proposal.id, item.mission != nil)
    }
  }
}

#Preview {
  ActivityView(viewModel: .preview())
}
