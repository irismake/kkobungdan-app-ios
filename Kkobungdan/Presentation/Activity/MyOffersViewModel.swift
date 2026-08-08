//
//  MyOffersViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/26/26.
//
//  '내 활동' 탭의 '웨이팅 기록' 세그먼트 데이터 소스.
//  - /v1/offer/own → [MyOffer]
//    offer 카드 표시에 필요한 proposal 상세는 /v1/proposal/{id} 로 별도 조회한다.
//

import Foundation

@Observable
final class MyOffersViewModel: LoadableViewModel {
  var myOffers: [MyOffer] = []
  /// offer 카드 표시용. offerID → ProposalDetail
  var proposalByOfferID: [Int64: ProposalDetail] = [:]
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
    await withLoading(fallback: "웨이팅 기록을 불러오지 못했어요.") {
      let offers = try await fetchMyOffersUseCase.execute(status: status)
      myOffers = offers

      proposalByOfferID = await loadProposals(for: offers)
    }
  }

  /// offer 카드용 proposal 상세를 병렬 조회한다.
  private func loadProposals(for offers: [MyOffer]) async -> [Int64: ProposalDetail] {
    await withTaskGroup(of: (Int64, ProposalDetail)?.self) { group in
      for offer in offers {
        group.addTask {
          guard let proposal = try? await self.fetchProposalDetailUseCase.execute(id: offer.proposalID) else {
            return nil
          }
          return (offer.id, proposal)
        }
      }
      var map: [Int64: ProposalDetail] = [:]
      for await result in group {
        if let (offerID, proposal) = result {
          map[offerID] = proposal
        }
      }
      return map
    }
  }
}
