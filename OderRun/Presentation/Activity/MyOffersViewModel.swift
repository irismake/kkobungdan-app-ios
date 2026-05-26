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
  var isCancellingOfferID: Int64?

  private let fetchMyOffersUseCase: FetchMyOffersUseCase
  private let fetchProposalDetailUseCase: FetchProposalDetailUseCase
  private let cancelOfferUseCase: CancelOfferUseCase

  init(
    fetchMyOffersUseCase: FetchMyOffersUseCase,
    fetchProposalDetailUseCase: FetchProposalDetailUseCase,
    cancelOfferUseCase: CancelOfferUseCase
  ) {
    self.fetchMyOffersUseCase = fetchMyOffersUseCase
    self.fetchProposalDetailUseCase = fetchProposalDetailUseCase
    self.cancelOfferUseCase = cancelOfferUseCase
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let offers = try await fetchMyOffersUseCase.execute()
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

  /// 러너가 본인이 제출한 지원(WAITING)을 취소한다. 성공 시 목록을 다시 로드한다.
  @MainActor
  func cancelMyOffer(offerID: Int64) async {
    guard isCancellingOfferID == nil else {
      return
    }
    isCancellingOfferID = offerID
    errorMessage = nil
    do {
      try await cancelOfferUseCase.execute(offerID: offerID)
      await load()
    } catch {
      errorMessage = "지원을 취소하지 못했어요."
    }
    isCancellingOfferID = nil
  }
}
