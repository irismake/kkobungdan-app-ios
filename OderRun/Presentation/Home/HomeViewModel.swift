//
//  HomeViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class HomeViewModel {
  var proposals: [Proposal] = []
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchProposalsUseCase: FetchProposalsUseCase

  init(fetchProposalsUseCase: FetchProposalsUseCase) {
    self.fetchProposalsUseCase = fetchProposalsUseCase
  }

  static func preview() -> HomeViewModel {
    let vm = HomeViewModel(
      fetchProposalsUseCase: FetchProposalsUseCase(repository: DIContainer.proposalRepository)
    )
    vm.proposals = Proposal.dummyList
    return vm
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      proposals = try await fetchProposalsUseCase.execute()
    } catch {
      errorMessage = "요청 목록을 불러오지 못했어요."
    }
    isLoading = false
  }
}
