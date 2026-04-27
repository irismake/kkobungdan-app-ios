//
//  MyProposalDetailViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class MyProposalDetailViewModel {
  let proposalID: Int64

  var proposal: Proposal?
  var offers: [Offer] = []
  var isLoading: Bool = false
  var errorMessage: String?
  var isCancelling: Bool = false
  var didCancel: Bool = false

  /// 의뢰자 입장에서의 미션 상태/액션을 다룬다.
  let missionViewModel: MissionDetailViewModel

  var applicantCount: Int {
    offers.filter { $0.status == .waiting || $0.status == .accepted }.count
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersUseCase: FetchOffersByProposalUseCase
  private let cancelProposalUseCase: CancelProposalUseCase

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    cancelProposalUseCase: CancelProposalUseCase,
    missionViewModel: MissionDetailViewModel
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.cancelProposalUseCase = cancelProposalUseCase
    self.missionViewModel = missionViewModel
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let proposalTask = fetchDetailUseCase.execute(id: proposalID)
      async let offersTask = fetchOffersUseCase.execute(proposalID: proposalID)
      proposal = try await proposalTask
      offers = try await offersTask
    } catch {
      errorMessage = "내 요청 상세를 불러오지 못했어요."
    }
    isLoading = false
    await missionViewModel.load()
  }

  @MainActor
  func cancelProposal() async {
    guard !isCancelling else {
      return
    }
    isCancelling = true
    errorMessage = nil
    do {
      proposal = try await cancelProposalUseCase.execute(id: proposalID)
      didCancel = true
    } catch {
      errorMessage = "요청을 취소하지 못했어요."
    }
    isCancelling = false
  }
}
