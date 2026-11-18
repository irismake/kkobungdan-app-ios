//
//  ProposalDetailViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class ProposalDetailViewModel: LoadableViewModel {
  let proposalID: Int64

  var proposal: ProposalDetail?
  var isLoading: Bool = false
  var errorMessage: String?
  /// 이 요청에 대한 내 지원 ID (상태 무관 — 재지원 불가라 한 건). 있으면 내 지원 상세로 교체된다.
  var myOfferID: Int64?

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
    await withLoading(fallback: "요청 상세를 불러오지 못했어요.") {
      async let proposalTask = fetchDetailUseCase.execute(id: proposalID)
      async let offersTask = fetchOffersByProposalUseCase.execute(proposalID: proposalID)
      let (proposal, offers) = try await (proposalTask, offersTask)
      self.proposal = proposal
      let currentUserID = tokenStorage.userID
      myOfferID = offers.last { $0.runnerID == currentUserID }?.id
    }
  }
}
