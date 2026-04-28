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

  var proposal: Proposal?
  var ordererProfile: RunnerProfile?
  var isLoading: Bool = false
  var errorMessage: String?
  var isApplying: Bool = false
  var hasApplied: Bool = false

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let createOfferUseCase: CreateOfferUseCase
  private let fetchMyOffersUseCase: FetchMyOffersUseCase
  private let userRepository: UserRepositoryProtocol

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    createOfferUseCase: CreateOfferUseCase,
    fetchMyOffersUseCase: FetchMyOffersUseCase,
    userRepository: UserRepositoryProtocol
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.createOfferUseCase = createOfferUseCase
    self.fetchMyOffersUseCase = fetchMyOffersUseCase
    self.userRepository = userRepository
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let proposal = try await fetchDetailUseCase.execute(id: proposalID)
      self.proposal = proposal
      ordererProfile = try await userRepository.fetchRunnerProfile(userID: proposal.ordererID)
      let myOffers = try await fetchMyOffersUseCase.execute(status: .waiting)
      hasApplied = myOffers.contains { $0.proposalID == proposalID }
    } catch {
      errorMessage = "요청 상세를 불러오지 못했어요."
    }
    isLoading = false
  }

  @MainActor
  func apply() async -> Bool {
    guard !isApplying, !hasApplied else {
      return false
    }
    isApplying = true
    errorMessage = nil
    do {
      _ = try await createOfferUseCase.execute(proposalID: proposalID)
      hasApplied = true
      isApplying = false
      return true
    } catch {
      errorMessage = "지원에 실패했어요. 잠시 후 다시 시도해주세요."
    }
    isApplying = false
    return false
  }
}
