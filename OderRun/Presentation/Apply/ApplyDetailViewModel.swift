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
  let offerID: Int64

  var proposal: Proposal?
  /// 의뢰자(orderer) 프로필.
  var runnerProfile: RunnerProfile?
  var isLoading: Bool = false
  var errorMessage: String?

  var myOffer: MyOffer?
  var mission: Mission?
  var isCompletingMission: Bool = false

  /// "만났어요!" 버튼 노출 여부. 내 offer 가 ACCEPTED 이면 노출.
  var canCompleteDelivery: Bool {
    myOffer?.status == .accepted
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchMyOffersUseCase: FetchMyOffersUseCase
  private let fetchMissionByOfferUseCase: FetchMissionByOfferUseCase
  private let updateMissionActionUseCase: UpdateMissionActionUseCase
  private let userRepository: UserRepositoryProtocol

  init(
    proposalID: Int64,
    offerID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchMyOffersUseCase: FetchMyOffersUseCase,
    fetchMissionByOfferUseCase: FetchMissionByOfferUseCase,
    updateMissionActionUseCase: UpdateMissionActionUseCase,
    userRepository: UserRepositoryProtocol
  ) {
    self.proposalID = proposalID
    self.offerID = offerID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchMyOffersUseCase = fetchMyOffersUseCase
    self.fetchMissionByOfferUseCase = fetchMissionByOfferUseCase
    self.updateMissionActionUseCase = updateMissionActionUseCase
    self.userRepository = userRepository
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let proposal = try await fetchDetailUseCase.execute(id: proposalID)
      self.proposal = proposal

      runnerProfile = try await userRepository.fetchRunnerProfile(userID: proposal.ordererID)

      let mine = try await fetchMyOffersUseCase.execute()
      myOffer = mine.first { $0.proposalID == proposalID }
      if myOffer?.status == .accepted || myOffer?.status == .complete {
        mission = try await fetchMissionByOfferUseCase.execute(offerID: offerID)
      } else {
        mission = nil
      }
    } catch {
      errorMessage = "지원 상세를 불러오지 못했어요."
    }
    isLoading = false
  }

  /// 러너 전달 완료. `PUT /v1/mission/{id}` — `COMPLETE_DELIVERY`
  @MainActor
  func completeDelivery() async {
    guard let mission, canCompleteDelivery, !isCompletingMission else {
      return
    }
    isCompletingMission = true
    errorMessage = nil
    do {
      let proofURL = "https://cdn.orderrun.com/proofs/mission-\(mission.id).jpg"
      _ = try await updateMissionActionUseCase.execute(
        id: mission.id,
        action: .completeDelivery,
        proofImageURL: proofURL
      )
      await load()
    } catch {
      errorMessage = "진행 완료 처리에 실패했어요. 잠시 후 다시 시도해주세요."
    }
    isCompletingMission = false
  }
}
