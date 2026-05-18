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
  var isRejecting: Bool = false
  var isAccepting: Bool = false
  var didAcceptOffer: Bool = false

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersUseCase: FetchOffersByProposalUseCase
  private let userRepository: UserRepositoryProtocol
  private let acceptOfferUseCase: AcceptOfferUseCase

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    userRepository: UserRepositoryProtocol,
    acceptOfferUseCase: AcceptOfferUseCase
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.userRepository = userRepository
    self.acceptOfferUseCase = acceptOfferUseCase
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

  /// 의뢰자가 지원자를 선택(수락)한다. `POST /v1/offer/{offerId}/accept` 호출로 cascade 가
  /// 일어나며 미션은 서버에서 함께 생성된다. runFee/itemPrice 는 추후 의뢰자가 입력할 값이지만
  /// 현재는 proposal 의 errandFee 로 기본값 처리.
  @MainActor
  func acceptOffer(offerID: Int64, runFee: Int? = nil, itemPrice: Int = 0) async {
    guard !isAccepting else {
      return
    }
    isAccepting = true
    didAcceptOffer = false
    errorMessage = nil
    do {
      let resolvedFee = runFee ?? proposal?.errandFee ?? 0
      _ = try await acceptOfferUseCase.execute(
        offerID: offerID,
        runFee: resolvedFee,
        itemPrice: itemPrice
      )
      didAcceptOffer = true
    } catch {
      errorMessage = "지원자 수락에 실패했어요. 잠시 후 다시 시도해주세요."
    }
    isAccepting = false
  }
}
