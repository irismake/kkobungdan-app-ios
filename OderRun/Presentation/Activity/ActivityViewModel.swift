//
//  ActivityViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//
//  '내 활동' 탭의 데이터 소스. 의뢰자(orderer) / 러너(runner) 역할별로 내 proposal / offer 와
//  연결된 mission 을 한 번에 불러와 화면에 노출한다. mission 이 아직 없는 단계(지원 대기,
//  지원자 검토 대기 등)도 모두 포함된다.
//

import Foundation

enum ActivityStage {
  case unpaid
  case waiting
  case inProgress
  case completed
  case cancelled
}

struct ActivityItem: Identifiable, Equatable {
  let proposal: Proposal
  /// runner 활동인 경우의 내 지원. orderer 활동에서는 nil.
  let offer: Offer?
  let mission: Mission?

  var id: String {
    if let offer {
      return "offer-\(offer.id)"
    }
    return "proposal-\(proposal.id)"
  }

  /// 오퍼 > 프로포절 순으로 현재 카드의 단계를 결정한다. mission 상태는 영향을 주지 않는다.
  var stage: ActivityStage {
    if let offer {
      switch offer.status {
      case .waiting:
        return .waiting
      case .accepted:
        return .inProgress
      case .complete:
        return .completed
      case .rejected, .cancelled:
        return .cancelled
      }
    }
    switch proposal.status {
    case .posted:
      return .unpaid
    case .waiting, .offered:
      return .waiting
    case .matched:
      return .inProgress
    case .complete:
      return .completed
    case .cancelled:
      return .cancelled
    }
  }
}

@Observable
final class ActivityViewModel {
  var ordererItems: [ActivityItem] = []
  var runnerItems: [ActivityItem] = []
  var isLoading: Bool = false
  var errorMessage: String?
  var isCancellingOfferID: Int64?

  private let fetchProposalsUseCase: FetchProposalsUseCase
  private let fetchMyOffersUseCase: FetchMyOffersUseCase
  private let fetchMyActivitiesUseCase: FetchMyActivitiesUseCase
  private let cancelOfferUseCase: CancelOfferUseCase
  private let proposalRepository: ProposalRepositoryProtocol

  init(
    fetchProposalsUseCase: FetchProposalsUseCase,
    fetchMyOffersUseCase: FetchMyOffersUseCase,
    fetchMyActivitiesUseCase: FetchMyActivitiesUseCase,
    cancelOfferUseCase: CancelOfferUseCase,
    proposalRepository: ProposalRepositoryProtocol
  ) {
    self.fetchProposalsUseCase = fetchProposalsUseCase
    self.fetchMyOffersUseCase = fetchMyOffersUseCase
    self.fetchMyActivitiesUseCase = fetchMyActivitiesUseCase
    self.cancelOfferUseCase = cancelOfferUseCase
    self.proposalRepository = proposalRepository
  }

  static func preview() -> ActivityViewModel {
    ActivityViewModel(
      fetchProposalsUseCase: FetchProposalsUseCase(repository: DIContainer.proposalRepository),
      fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.offerRepository),
      fetchMyActivitiesUseCase: FetchMyActivitiesUseCase(repository: DIContainer.activityRepository),
      cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository),
      proposalRepository: DIContainer.proposalRepository
    )
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let proposalsTask = fetchProposalsUseCase.execute(page: 0, size: 100)
      async let offersTask = fetchMyOffersUseCase.execute()
      async let ordererMissionsTask = fetchMyActivitiesUseCase.execute(role: .orderer)
      async let runnerMissionsTask = fetchMyActivitiesUseCase.execute(role: .runner)

      let (allProposals, myOffers, ordererMissions, runnerMissions) =
        try await (proposalsTask, offersTask, ordererMissionsTask, runnerMissionsTask)

      let myProposals = allProposals.filter { $0.ordererID == DummySession.currentUserID }
      ordererItems = myProposals
        .map { proposal in
          let mission = ordererMissions.first { $0.proposalID == proposal.id }
          return ActivityItem(proposal: proposal, offer: nil, mission: mission)
        }
        .sorted { $0.proposal.id > $1.proposal.id }

      runnerItems = await Self.makeRunnerItems(
        offers: myOffers,
        missions: runnerMissions,
        repository: proposalRepository
      )
    } catch {
      errorMessage = "내 활동을 불러오지 못했어요."
    }
    isLoading = false
  }

  /// 러너가 본인이 제출한 지원(WAITING)을 취소한다. 성공 시 활동 목록을 다시 로드한다.
  @MainActor
  func cancelMyOffer(offerID: Int64) async {
    guard isCancellingOfferID == nil else {
      return
    }
    isCancellingOfferID = offerID
    errorMessage = nil
    do {
      try await cancelOfferUseCase.execute(offerID: offerID)
      await load()
    } catch {
      errorMessage = "지원을 취소하지 못했어요."
    }
    isCancellingOfferID = nil
  }

  /// 같은 proposalID 에 여러 offer 가 쌓일 수 있음(취소/거절 후 재지원 등). 화면에는 가장
  /// 최근 offer 한 건만 노출한다.
  private static func makeRunnerItems(
    offers: [Offer],
    missions: [Mission],
    repository: ProposalRepositoryProtocol
  ) async -> [ActivityItem] {
    var latestOfferByProposal: [Int64: Offer] = [:]
    for offer in offers {
      if let existing = latestOfferByProposal[offer.proposalID], existing.createdAt >= offer.createdAt {
        continue
      }
      latestOfferByProposal[offer.proposalID] = offer
    }

    var items: [ActivityItem] = []
    for offer in latestOfferByProposal.values {
      guard let proposal = try? await repository.fetchProposal(id: offer.proposalID) else {
        continue
      }
      let mission = missions.first { $0.proposalID == offer.proposalID }
      items.append(ActivityItem(proposal: proposal, offer: offer, mission: mission))
    }
    return items.sorted { ($0.offer?.createdAt ?? .distantPast) > ($1.offer?.createdAt ?? .distantPast) }
  }
}
