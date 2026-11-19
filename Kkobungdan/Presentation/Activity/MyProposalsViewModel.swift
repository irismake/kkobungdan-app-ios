//
//  MyProposalsViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/26/26.
//
//  '내 활동' 탭의 '요청' 세그먼트 데이터 소스.
//  - /v1/proposal/own → [MyProposal]
//

import Foundation

@Observable
final class MyProposalsViewModel: LoadableViewModel {
  var myProposals: [MyProposal] = []
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchMyProposalsUseCase: FetchMyProposalsUseCase

  init(fetchMyProposalsUseCase: FetchMyProposalsUseCase) {
    self.fetchMyProposalsUseCase = fetchMyProposalsUseCase
  }

  @MainActor
  func load(status: [ProposalStatus] = []) async {
    await withLoading(fallback: "내 요청을 불러오지 못했어요.") {
      myProposals = try await fetchMyProposalsUseCase.execute(status: status)
    }
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension MyProposalsViewModel {
  static func preview() -> MyProposalsViewModel {
    MyProposalsViewModel(
      fetchMyProposalsUseCase: FetchMyProposalsUseCase(repository: DIContainer.activityRepository)
    )
  }
}
