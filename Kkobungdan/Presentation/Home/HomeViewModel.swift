//
//  HomeViewModel.swift
//  Kkobungdan
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
    let viewModel = HomeViewModel(
      fetchProposalsUseCase: FetchProposalsUseCase(repository: DIContainer.proposalRepository)
    )
    viewModel.proposals = Proposal.dummyList
    return viewModel
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      // 홈 피드는 아직 지원 가능한 공개 요청(등록 완료 / 새 지원 도착)만 노출한다.
      proposals = try await fetchProposalsUseCase.execute(status: [.posted, .offered])
    } catch {
      errorMessage = error.userMessage(fallback: "요청 목록을 불러오지 못했어요.")
    }
    isLoading = false
  }
}
