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
  /// 의뢰자(orderer) 입장에서 지원자를 검토할 때 전달받는 offer ID. nil 이면 일반 '내 지원 상세' 모드.
  let offerID: Int64?

  var proposal: Proposal?
  /// acceptMode(orderer) 에서는 지원한 러너의 프로필, 아니면 의뢰자(orderer) 프로필.
  var counterpartProfile: RunnerProfile?
  var isLoading: Bool = false
  var errorMessage: String?

  var isAccepting: Bool = false
  var didAcceptOffer: Bool = false

  /// 러너 입장에서 본인의 미션 상태를 다루는 sub view model. orderer 모드에서는 nil.
  let missionViewModel: MissionDetailViewModel?

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersUseCase: FetchOffersByProposalUseCase
  private let userRepository: UserRepositoryProtocol
  private let acceptOfferUseCase: AcceptOfferUseCase

  init(
    proposalID: Int64,
    offerID: Int64? = nil,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    userRepository: UserRepositoryProtocol,
    acceptOfferUseCase: AcceptOfferUseCase,
    missionViewModel: MissionDetailViewModel? = nil
  ) {
    self.proposalID = proposalID
    self.offerID = offerID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.userRepository = userRepository
    self.acceptOfferUseCase = acceptOfferUseCase
    self.missionViewModel = missionViewModel
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let proposal = try await fetchDetailUseCase.execute(id: proposalID)
      self.proposal = proposal

      let counterpartUserID = try await resolveCounterpartUserID(proposal: proposal)
      counterpartProfile = try await userRepository.fetchRunnerProfile(userID: counterpartUserID)
    } catch {
      errorMessage = "지원 상세를 불러오지 못했어요."
    }
    isLoading = false
    if let missionViewModel {
      await missionViewModel.load()
    }
  }

  /// 의뢰자가 지원자를 수락한다. `POST /v1/offer/{offerId}/accept` 호출로 매칭 cascade 가 일어나고
  /// 미션은 서버에서 함께 생성된다. runFee/itemPrice 는 추후 의뢰자가 입력할 값이지만 현재는
  /// proposal 의 errandFee 로 기본값 처리.
  @MainActor
  func acceptOffer(runFee: Int? = nil, itemPrice: Int = 0) async {
    guard let offerID, !isAccepting else {
      return
    }
    isAccepting = true
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

  /// orderer 모드에서는 지원한 러너의 ID, runner 모드에서는 의뢰자(orderer) ID.
  private func resolveCounterpartUserID(proposal: Proposal) async throws -> String {
    guard let offerID else {
      return proposal.ordererID
    }
    let offers = try await fetchOffersUseCase.execute(proposalID: proposalID)
    if let offer = offers.first(where: { $0.id == offerID }) {
      return offer.runnerID
    }
    return proposal.ordererID
  }
}
