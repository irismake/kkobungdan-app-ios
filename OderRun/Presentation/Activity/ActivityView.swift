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
  case cancelled = "취소"

  func matches(_ stage: ActivityStage) -> Bool {
    switch self {
    case .all: return true
    case .unpaid: return stage == .unpaid
    case .waiting: return stage == .waiting
    case .inProgress: return stage == .inProgress
    case .completed: return stage == .completed
    case .cancelled: return stage == .cancelled
    }
  }
}

struct ActivityView: View {
  @State private var proposalsViewModel: MyProposalsViewModel
  @State private var offersViewModel: MyOffersViewModel
  @State private var segment: ActivitySegment = .orderer
  @State private var filter: ActivityFilter = .all
  @State private var pendingCancelOffer: MyOffer?

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
    .task {
      async let proposalsTask: Void = proposalsViewModel.load()
      async let offersTask: Void = offersViewModel.load()
      _ = await (proposalsTask, offersTask)
    }
    .refreshable {
      async let proposalsTask: Void = proposalsViewModel.load()
      async let offersTask: Void = offersViewModel.load()
      _ = await (proposalsTask, offersTask)
    }
    .alert(
      "지원을 취소할까요?",
      isPresented: Binding(
        get: { pendingCancelOffer != nil },
        set: { if !$0 {
          pendingCancelOffer = nil
        } }
      ),
      presenting: pendingCancelOffer
    ) { entry in
      Button("취소", role: .cancel) {
        pendingCancelOffer = nil
      }
      Button("지원 취소", role: .destructive) {
        Task { await offersViewModel.cancelMyOffer(offerID: entry.id) }
      }
    } message: { _ in
      Text("지원을 취소하면 되돌릴 수 없어요.")
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
    let items = proposalsViewModel.myProposals.filter { filter.matches($0.stage) }
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
    let items = offersViewModel.myOffers.filter { filter.matches($0.stage) }
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
        VStack(spacing: 8) {
          card(for: offer)
            .contentShape(Rectangle())
            .onTapGesture {
              onSelectRunnerItem(offer.proposalID, offer.id)
            }

          if offer.status == .waiting {
            cancelOfferButton(for: offer)
          }
        }
      }
    }
  }

  private func cancelOfferButton(for offer: MyOffer) -> some View {
    let isCancelling = offersViewModel.isCancellingOfferID == offer.id
    return Button {
      pendingCancelOffer = offer
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
      fetchProposalDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository)
    )
  )
}
