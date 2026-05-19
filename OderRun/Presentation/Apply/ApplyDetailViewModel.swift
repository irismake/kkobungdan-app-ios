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
  var isLoading: Bool = false
  var errorMessage: String?

  var myOffer: MyOffer?
  var mission: Mission?
  var isCompletingMission: Bool = false

  /// "만났어요!" 버튼 노출 여부.
  /// 내 offer 가 ACCEPTED 이고, 미션이 아직 내(러너) 확인을 받지 않은 상태일 때만 노출.
  /// (이미 내가 확인했다면 상대방 대기 상태이므로 다시 누를 수 없다.)
  var canCompleteDelivery: Bool {
    guard myOffer?.status == .accepted, let mission else {
      return false
    }
    switch mission.status {
    case .created, .inProgress, .receivedConfirmed:
      return true
    default:
      return false
    }
  }

  /// 러너가 "만났어요!"를 이미 눌렀고, 요청자(의뢰자) 확인을 기다리는 중인지 여부.
  var isWaitingForOrdererConfirm: Bool {
    myOffer?.status == .accepted && mission?.status == .deliveryCompleted
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchMyOffersUseCase: FetchMyOffersUseCase
  private let fetchMissionByOfferUseCase: FetchMissionByOfferUseCase
  private let updateMissionActionUseCase: UpdateMissionActionUseCase

  init(
    proposalID: Int64,
    offerID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchMyOffersUseCase: FetchMyOffersUseCase,
    fetchMissionByOfferUseCase: FetchMissionByOfferUseCase,
    updateMissionActionUseCase: UpdateMissionActionUseCase
  ) {
    self.proposalID = proposalID
    self.offerID = offerID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchMyOffersUseCase = fetchMyOffersUseCase
    self.fetchMissionByOfferUseCase = fetchMissionByOfferUseCase
    self.updateMissionActionUseCase = updateMissionActionUseCase
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let proposal = try await fetchDetailUseCase.execute(id: proposalID)
      self.proposal = proposal

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
