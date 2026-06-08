//
//  MyProposalDetailViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class MyProposalDetailViewModel {
  let proposalID: Int64

  var proposal: Proposal?
  var offers: [Offer] = []
  var matchedOfferDetail: OfferDetail?
  var matchedRunnerProfile: RunnerProfile?
  var isLoading: Bool = false
  var errorMessage: String?
  var isCancelling: Bool = false
  var didCancel: Bool = false
  var mission: Mission?
  var isCompletingMission: Bool = false

  /// "만났어요!" 버튼 노출 여부.
  /// proposal 이 MATCHED 이고, 미션이 아직 내(요청자) 확인을 받지 않은 상태일 때만 노출.
  /// (이미 내가 확인했다면 상대방 대기 상태이므로 다시 누를 수 없다.)
  var canConfirmReceived: Bool {
    guard proposal?.status == .matched, let mission else {
      return false
    }
    switch mission.status {
    case .created, .inProgress, .deliveryCompleted:
      return true
    default:
      return false
    }
  }

  /// 의뢰자가 "만났어요!"를 이미 눌렀고, 러너 확인을 기다리는 중인지 여부.
  var isWaitingForRunnerConfirm: Bool {
    proposal?.status == .matched && mission?.status == .receivedConfirmed
  }

  var applicantCount: Int {
    offers.filter { $0.status == .waiting || $0.status == .accepted }.count
  }

  /// 매칭된 (수락된) offer. 매칭이 완료된 proposal 에서 매칭 러너 카드 표시에 사용.
  var matchedOffer: Offer? {
    offers.first(where: { $0.status == .accepted })
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersUseCase: FetchOffersByProposalUseCase
  private let fetchOfferDetailUseCase: FetchOfferDetailUseCase
  private let fetchRunnerProfileUseCase: FetchRunnerProfileUseCase
  private let fetchMissionByProposalUseCase: FetchMissionByProposalUseCase
  private let updateMissionActionUseCase: UpdateMissionActionUseCase
  private let cancelProposalUseCase: CancelProposalUseCase

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    fetchOfferDetailUseCase: FetchOfferDetailUseCase,
    fetchRunnerProfileUseCase: FetchRunnerProfileUseCase,
    fetchMissionByProposalUseCase: FetchMissionByProposalUseCase,
    updateMissionActionUseCase: UpdateMissionActionUseCase,
    cancelProposalUseCase: CancelProposalUseCase
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.fetchOfferDetailUseCase = fetchOfferDetailUseCase
    self.fetchRunnerProfileUseCase = fetchRunnerProfileUseCase
    self.fetchMissionByProposalUseCase = fetchMissionByProposalUseCase
    self.updateMissionActionUseCase = updateMissionActionUseCase
    self.cancelProposalUseCase = cancelProposalUseCase
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let proposalTask = fetchDetailUseCase.execute(id: proposalID)
      async let offersTask = fetchOffersUseCase.execute(proposalID: proposalID)
      proposal = try await proposalTask
      offers = try await offersTask

      if let matchedOffer {
        async let detailTask = fetchOfferDetailUseCase.execute(offerID: matchedOffer.id)
        async let profileTask = fetchRunnerProfileUseCase.execute(runnerID: matchedOffer.runnerID)
        let (detail, profile) = try await (detailTask, profileTask)
        matchedOfferDetail = detail
        matchedRunnerProfile = profile
      } else {
        matchedOfferDetail = nil
        matchedRunnerProfile = nil
      }

      // proposal 이 MATCHED 이후라면 미션이 존재한다. 그 외 상태에서는 nil.
      if proposal?.status == .matched || proposal?.status == .complete {
        mission = try await fetchMissionByProposalUseCase.execute(proposalID: proposalID)
      } else {
        mission = nil
      }
    } catch {
      errorMessage = "내 요청 상세를 불러오지 못했어요."
    }
    isLoading = false
  }

  /// 오더 수령 확인. `POST /v1/mission/{id}/confirm-received`
  @MainActor
  func confirmReceived() async {
    guard let mission, canConfirmReceived, !isCompletingMission else {
      return
    }
    isCompletingMission = true
    errorMessage = nil
    do {
      _ = try await updateMissionActionUseCase.execute(
        id: mission.id,
        action: .confirmReceived
      )
      await load()
    } catch {
      errorMessage = "진행 완료 처리에 실패했어요. 잠시 후 다시 시도해주세요."
    }
    isCompletingMission = false
  }

  @MainActor
  func cancelProposal() async {
    guard !isCancelling else {
      return
    }
    isCancelling = true
    errorMessage = nil
    do {
      proposal = try await cancelProposalUseCase.execute(id: proposalID)
      didCancel = true
    } catch {
      errorMessage = "요청을 취소하지 못했어요."
    }
    isCancelling = false
  }
}
