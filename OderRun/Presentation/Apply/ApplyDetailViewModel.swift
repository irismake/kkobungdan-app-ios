//
//  ApplyDetailViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class ApplyDetailViewModel {
  let proposalID: Int64

  var proposal: Proposal?
  var ordererProfile: RunnerProfile?
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let userRepository: UserRepositoryProtocol

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    userRepository: UserRepositoryProtocol
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
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
    } catch {
      errorMessage = "지원 상세를 불러오지 못했어요."
    }
    isLoading = false
  }
}
