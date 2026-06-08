//
//  MyOffersViewModel.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  '내 활동' 탭의 '웨이팅 기록' 세그먼트 데이터 소스.
//  - /v1/offer/own → [MyOffer]
//    offer 카드 표시에 필요한 proposal 상세는 /v1/proposal/{id} 로 별도 조회한다.
//

import Foundation

@Observable
final class MyOffersViewModel {
  var myOffers: [MyOffer] = []
  /// offer 카드 표시용. offerID → Proposal
  var proposalByOfferID: [Int64: Proposal] = [:]
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchMyOffersUseCase: FetchMyOffersUseCase
  private let fetchProposalDetailUseCase: FetchProposalDetailUseCase

  init(
    fetchMyOffersUseCase: FetchMyOffersUseCase,
    fetchProposalDetailUseCase: FetchProposalDetailUseCase
  ) {
    self.fetchMyOffersUseCase = fetchMyOffersUseCase
    self.fetchProposalDetailUseCase = fetchProposalDetailUseCase
  }

  static func preview() -> MyOffersViewModel {
    MyOffersViewModel(
      fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.activityRepository),
      fetchProposalDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository)
    )
  }

  @MainActor
  func load(status: [OfferStatus] = []) async {
    isLoading = true
    errorMessage = nil
    do {
      let offers = try await fetchMyOffersUseCase.execute(status: status)
      myOffers = offers

      var map: [Int64: Proposal] = [:]
      try await withThrowingTaskGroup(of: (Int64, Proposal).self) { group in
        for offer in offers {
          group.addTask {
            let proposal = try await self.fetchProposalDetailUseCase.execute(id: offer.proposalID)
            return (offer.id, proposal)
          }
        }
        for try await (offerID, proposal) in group {
          map[offerID] = proposal
        }
      }
      proposalByOfferID = map
    } catch {
      errorMessage = "웨이팅 기록을 불러오지 못했어요."
    }
    isLoading = false
  }
}
