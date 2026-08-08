//
//  OfferListViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class OfferListViewModel {
  let proposalID: Int64

  var proposal: ProposalDetail?
  var runners: [Offer] = []
  var isLoading: Bool = false
  var errorMessage: String?
  var isRejecting: Bool = false
  var isAccepting: Bool = false
  var didAcceptOffer: Bool = false

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersUseCase: FetchOffersByProposalUseCase
  private let acceptOfferUseCase: AcceptOfferUseCase

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    acceptOfferUseCase: AcceptOfferUseCase
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.acceptOfferUseCase = acceptOfferUseCase
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      async let proposalTask = fetchDetailUseCase.execute(id: proposalID)
      async let offersTask = fetchOffersUseCase.execute(proposalID: proposalID)
      let (proposal, offers) = try await (proposalTask, offersTask)
      self.proposal = proposal
      runners = offers.filter { $0.status == .waiting || $0.status == .accepted }
    } catch {
      guard !error.isCancellation else {
        return
      }
      errorMessage = error.userMessage(fallback: "지원자 목록을 불러오지 못했어요.")
    }
  }

  /// 의뢰자가 지원자를 선택(수락)한다. `POST /v1/offer/{offerId}/accept` (무바디) 호출로
  /// proposal/offer 상태 전이 cascade 가 서버에서 처리된다.
  @MainActor
  func acceptOffer(offerID: Int64) async {
    guard !isAccepting else {
      return
    }
    isAccepting = true
    didAcceptOffer = false
    errorMessage = nil
    do {
      _ = try await acceptOfferUseCase.execute(offerID: offerID)
      NotificationCenter.default.post(name: .proposalListNeedsRefresh, object: nil)
      didAcceptOffer = true
    } catch {
      errorMessage = error.userMessage(fallback: "지원자 수락에 실패했어요. 잠시 후 다시 시도해주세요.")
    }
    isAccepting = false
  }
}
