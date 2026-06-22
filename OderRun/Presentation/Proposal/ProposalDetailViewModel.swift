//
//  ProposalDetailViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class ProposalDetailViewModel {
  let proposalID: Int64

  var proposal: ProposalDetail?
  var isLoading: Bool = false
  var errorMessage: String?
  var hasApplied: Bool = false

  var isMine: Bool {
    guard let proposal else {
      return false
    }
    return proposal.ordererID == tokenStorage.userID
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersByProposalUseCase: FetchOffersByProposalUseCase
  private let tokenStorage: TokenStorage

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersByProposalUseCase: FetchOffersByProposalUseCase,
    tokenStorage: TokenStorage = .shared
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersByProposalUseCase = fetchOffersByProposalUseCase
    self.tokenStorage = tokenStorage
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let proposalTask = fetchDetailUseCase.execute(id: proposalID)
      async let offersTask = fetchOffersByProposalUseCase.execute(proposalID: proposalID)
      let (proposal, offers) = try await (proposalTask, offersTask)
      self.proposal = proposal
      let currentUserID = tokenStorage.userID
      hasApplied = offers.contains {
        $0.runnerID == currentUserID && ($0.status == .waiting || $0.status == .accepted)
      }
    } catch {
      errorMessage = "요청 상세를 불러오지 못했어요."
    }
    isLoading = false
  }
}
