//
//  ActivityViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//
//  '내 활동' 탭의 데이터 소스.
//  - 내 요청(orderer): /v1/proposal/own → [MyProposal]
//  - 웨이팅 기록(runner): /v1/offer/own → [MyOffer]
//

import Foundation

enum ActivityStage {
  case unpaid
  case waiting
  case inProgress
  case completed
  case cancelled
}

extension MyProposal {
  var stage: ActivityStage {
    switch status {
    case .posted, .holding: return .unpaid
    case .waiting, .offered: return .waiting
    case .matched: return .inProgress
    case .complete: return .completed
    case .cancelled: return .cancelled
    }
  }
}

extension MyOffer {
  var stage: ActivityStage {
    switch status {
    case .waiting: return .waiting
    case .accepted: return .inProgress
    case .complete: return .completed
    case .rejected, .cancelled: return .cancelled
    }
  }
}

@Observable
final class ActivityViewModel {
  var myProposals: [MyProposal] = []
  var myOffers: [MyOffer] = []
  var isLoading: Bool = false
  var errorMessage: String?
  var isCancellingOfferID: Int64?

  private let fetchMyProposalsUseCase: FetchMyProposalsUseCase
  private let fetchMyOffersUseCase: FetchMyOffersUseCase
  private let cancelOfferUseCase: CancelOfferUseCase

  init(
    fetchMyProposalsUseCase: FetchMyProposalsUseCase,
    fetchMyOffersUseCase: FetchMyOffersUseCase,
    cancelOfferUseCase: CancelOfferUseCase
  ) {
    self.fetchMyProposalsUseCase = fetchMyProposalsUseCase
    self.fetchMyOffersUseCase = fetchMyOffersUseCase
    self.cancelOfferUseCase = cancelOfferUseCase
  }

  static func preview() -> ActivityViewModel {
    ActivityViewModel(
      fetchMyProposalsUseCase: FetchMyProposalsUseCase(repository: DIContainer.activityRepository),
      fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.activityRepository),
      cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository)
    )
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let proposalsTask = fetchMyProposalsUseCase.execute()
      async let offersTask = fetchMyOffersUseCase.execute()
      let (proposals, offers) = try await (proposalsTask, offersTask)
      myProposals = proposals
      myOffers = offers
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
}
