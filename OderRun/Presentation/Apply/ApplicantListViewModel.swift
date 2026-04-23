//
//  ApplicantListViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct ApplicantListEntry: Identifiable, Equatable {
  let offer: Offer
  let profile: RunnerProfile

  var id: Int64 {
    offer.id
  }
}

@Observable
final class ApplicantListViewModel {
  let proposalID: Int64

  var proposal: Proposal?
  var entries: [ApplicantListEntry] = []
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersUseCase: FetchOffersByProposalUseCase
  private let userRepository: UserRepositoryProtocol

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    userRepository: UserRepositoryProtocol
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.userRepository = userRepository
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let proposalTask = fetchDetailUseCase.execute(id: proposalID)
      async let offersTask = fetchOffersUseCase.execute(proposalID: proposalID)
      let (proposal, offers) = try await (proposalTask, offersTask)
      self.proposal = proposal

      var built: [ApplicantListEntry] = []
      for offer in offers where offer.status == .waiting || offer.status == .accepted {
        let profile = try await userRepository.fetchRunnerProfile(userID: offer.runnerID)
        built.append(ApplicantListEntry(offer: offer, profile: profile))
      }
      entries = built
    } catch {
      errorMessage = "지원자 목록을 불러오지 못했어요."
    }
    isLoading = false
  }
}
