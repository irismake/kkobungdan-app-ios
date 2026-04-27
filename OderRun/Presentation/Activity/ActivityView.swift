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
  case unpaid = "미입금"
  case waiting = "대기중"
  case inProgress = "진행중"
  case completed = "완료"
  case cancelled = "취소 / 환불"

  func matches(_ status: MissionStatus) -> Bool {
    switch self {
    case .all: return true
    case .unpaid: return status == .created
    case .waiting: return status == .inProgress
    case .inProgress: return status == .deliveryCompleted
    case .completed: return status == .receivedConfirmed || status == .settled
    case .cancelled: return status == .disputed || status == .refunded
    }
  }
}

struct ActivityView: View {
  @State private var viewModel: ActivityViewModel
  @State private var segment: ActivitySegment = .orderer
  @State private var filter: ActivityFilter = .all

  var onSelectOrdererProposal: (Int64) -> Void = { _ in }
  var onSelectRunnerProposal: (Int64, Int64) -> Void = { _, _ in }

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
    onSelectRunnerProposal: @escaping (Int64, Int64) -> Void = { _, _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onSelectOrdererProposal = onSelectOrdererProposal
    self.onSelectRunnerProposal = onSelectRunnerProposal
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
              activityCard(for: item)
                .contentShape(Rectangle())
                .onTapGesture {
                  handleSelection(item)
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
  }

  private var currentItems: [ActivityMissionItem] {
    switch segment {
    case .orderer: return viewModel.ordererMissions
    case .runner: return viewModel.runnerMissions
    }
  }

  private var filteredItems: [ActivityMissionItem] {
    currentItems.filter { filter.matches($0.mission.status) }
  }

  private var emptyMessage: String {
    switch segment {
    case .orderer: return "아직 진행 중인 의뢰가 없어요."
    case .runner: return "아직 진행 중인 지원이 없어요."
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

  @ViewBuilder
  private func activityCard(for item: ActivityMissionItem) -> some View {
    if let proposal = item.proposal {
      ProposalCard(
        title: proposal.title,
        description: proposal.content,
        date: ProposalDisplay.dateString(proposal.deadline),
        time: ProposalDisplay.timeString(proposal.deadline),
        fee: ProposalDisplay.feeString(proposal.errandFee),
        badges: [MissionDisplay.statusBadge(item.mission.status)]
      )
    } else {
      ProposalCard(
        title: "Proposal #\(item.mission.proposalID)",
        description: "더미 데이터: 매칭된 의뢰 정보를 찾을 수 없어요.",
        date: "-",
        time: "-",
        fee: ProposalDisplay.feeString(item.mission.runFee + item.mission.itemPrice),
        badges: [MissionDisplay.statusBadge(item.mission.status)]
      )
    }
  }

  private func handleSelection(_ item: ActivityMissionItem) {
    switch segment {
    case .orderer:
      onSelectOrdererProposal(item.mission.proposalID)
    case .runner:
      onSelectRunnerProposal(item.mission.proposalID, item.mission.offerID)
    }
  }
}

#Preview {
  ActivityView(viewModel: .preview())
}
