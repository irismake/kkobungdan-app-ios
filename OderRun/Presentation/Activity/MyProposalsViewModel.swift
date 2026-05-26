//
//  MyProposalsViewModel.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  '내 활동' 탭의 '요청' 세그먼트 데이터 소스.
//  - /v1/proposal/own → [MyProposal]
//

import Foundation

@Observable
final class MyProposalsViewModel {
  var myProposals: [MyProposal] = []
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchMyProposalsUseCase: FetchMyProposalsUseCase

  init(fetchMyProposalsUseCase: FetchMyProposalsUseCase) {
    self.fetchMyProposalsUseCase = fetchMyProposalsUseCase
  }

  static func preview() -> MyProposalsViewModel {
    MyProposalsViewModel(
      fetchMyProposalsUseCase: FetchMyProposalsUseCase(repository: DIContainer.activityRepository)
    )
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      myProposals = try await fetchMyProposalsUseCase.execute()
    } catch {
      errorMessage = "내 요청을 불러오지 못했어요."
    }
    isLoading = false
  }
}
