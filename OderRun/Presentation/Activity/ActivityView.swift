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
    case .runner: return "수행 기록"
    }
  }
}

enum ActivityFilter: String {
  case all = "전체"
  case unpaid = "미입금"
  case waiting = "대기중"
  case inProgress = "진행중"
  case completed = "완료"
  case cancelled = "취소"

  /// orderer(요청) 세그먼트 카테고리.
  static let ordererCases: [ActivityFilter] = [.all, .unpaid, .waiting, .inProgress, .completed, .cancelled]
  /// runner(웨이팅 기록) 세그먼트 카테고리. 러너 offer 에는 '미입금' 상태가 없다.
  static let runnerCases: [ActivityFilter] = [.all, .waiting, .inProgress, .completed, .cancelled]

  /// `/v1/proposal/own` 조회 시 보낼 status 필터. `all` 은 빈 배열(전체).
  var proposalStatuses: [ProposalStatus] {
    switch self {
    case .all: return []
    case .unpaid: return [.holding]
    case .waiting: return [.posted, .offered]
    case .inProgress: return [.matched, .orderCompleted, .disputed]
    case .completed: return [.allCompleted]
    case .cancelled: return [.cancelled, .resolved]
    }
  }

  /// `/v1/offer/own` 조회 시 보낼 status 필터. `all` 은 빈 배열(전체).
  var offerStatuses: [OfferStatus] {
    switch self {
    case .all, .unpaid: return []
    case .waiting: return [.waiting]
    case .inProgress: return [.accepted, .runnerCompleted, .disputed]
    case .completed: return [.allCompleted]
    case .cancelled: return [.rejected, .cancelled, .resolved]
    }
  }
}

struct ActivityView: View {
  @State private var proposalsViewModel: MyProposalsViewModel
  @State private var offersViewModel: MyOffersViewModel
  @State private var segment: ActivitySegment = .orderer
  @State private var filter: ActivityFilter = .all

  var onSelectOrdererProposal: (Int64) -> Void = { _ in }
  var onSelectRunnerItem: (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in }

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
    proposalsViewModel: MyProposalsViewModel,
    offersViewModel: MyOffersViewModel,
    onSelectOrdererProposal: @escaping (Int64) -> Void = { _ in },
    onSelectRunnerItem: @escaping (_ proposalID: Int64, _ offerID: Int64) -> Void = { _, _ in }
  ) {
    _proposalsViewModel = State(initialValue: proposalsViewModel)
    _offersViewModel = State(initialValue: offersViewModel)
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
          contentSection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
      }
      .background(Color.gray000)
    }
    // 세그먼트·카테고리가 바뀔 때마다 해당 목록을 status 필터를 적용해 다시 조회한다.
    .task(id: "\(segment.rawValue)-\(filter.rawValue)") {
      await reloadCurrentSegment()
    }
    .refreshable {
      await reloadCurrentSegment()
    }
  }

  private func reloadCurrentSegment() async {
    switch segment {
    case .orderer:
      await proposalsViewModel.load(status: filter.proposalStatuses)
    case .runner:
      await offersViewModel.load(status: filter.offerStatuses)
    }
  }

  @ViewBuilder
  private var contentSection: some View {
    switch segment {
    case .orderer:
      myProposalsContent
    case .runner:
      myOffersContent
    }
  }

  @ViewBuilder
  private var myProposalsContent: some View {
    let items = proposalsViewModel.myProposals
    if proposalsViewModel.isLoading, items.isEmpty {
      ProgressView().padding(.top, 40)
    } else if let errorMessage = proposalsViewModel.errorMessage, items.isEmpty {
      Text(errorMessage)
        .textStyle(.body3)
        .foregroundColor(Color.rose500)
        .padding(.top, 40)
    } else if items.isEmpty {
      Text("아직 등록한 의뢰가 없어요.")
        .textStyle(.body3)
        .foregroundColor(Color.gray500)
        .padding(.top, 40)
    } else {
      ForEach(items) { proposal in
        card(for: proposal)
          .contentShape(Rectangle())
          .onTapGesture {
            onSelectOrdererProposal(proposal.id)
          }
      }
    }
  }

  @ViewBuilder
  private var myOffersContent: some View {
    let items = offersViewModel.myOffers
    if offersViewModel.isLoading, items.isEmpty {
      ProgressView().padding(.top, 40)
    } else if let errorMessage = offersViewModel.errorMessage, items.isEmpty {
      Text(errorMessage)
        .textStyle(.body3)
        .foregroundColor(Color.rose500)
        .padding(.top, 40)
    } else if items.isEmpty {
      Text("아직 지원한 의뢰가 없어요.")
        .textStyle(.body3)
        .foregroundColor(Color.gray500)
        .padding(.top, 40)
    } else {
      ForEach(items) { offer in
        card(for: offer)
          .contentShape(Rectangle())
          .onTapGesture {
            onSelectRunnerItem(offer.proposalID, offer.id)
          }
      }
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
    let cases = segment == .orderer ? ActivityFilter.ordererCases : ActivityFilter.runnerCases
    return ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        ForEach(cases, id: \.self) { item in
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

  private func card(for proposal: MyProposal) -> some View {
    ProposalCard(
      title: proposal.title,
      description: proposal.content,
      date: ProposalDisplay.dateString(proposal.deadline),
      time: ProposalDisplay.timeString(proposal.deadline),
      fee: ProposalDisplay.feeString(proposal.errandFee),
      badges: ProposalDisplay.badges(myProposal: proposal)
    )
  }

  private func card(for offer: MyOffer) -> some View {
    let proposal = offersViewModel.proposalByOfferID[offer.id]
    return ProposalCard(
      title: proposal?.title ?? "",
      description: proposal?.content ?? "",
      date: ProposalDisplay.dateString(proposal?.deadline ?? offer.createdAt),
      time: ProposalDisplay.timeString(proposal?.deadline ?? offer.createdAt),
      fee: proposal.map { ProposalDisplay.feeString($0.errandFee) } ?? "",
      badges: ProposalDisplay.badges(myOffer: offer)
    )
  }
}

#Preview {
  ActivityView(
    proposalsViewModel: MyProposalsViewModel(
      fetchMyProposalsUseCase: FetchMyProposalsUseCase(repository: DIContainer.activityRepository)
    ),
    offersViewModel: MyOffersViewModel(
      fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.activityRepository),
      fetchProposalDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository)
    )
  )
}
