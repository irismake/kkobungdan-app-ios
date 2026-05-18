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
  var matchedRunnerProfile: RunnerProfile?
  var isLoading: Bool = false
  var errorMessage: String?
  var isCancelling: Bool = false
  var didCancel: Bool = false
  var mission: Mission?
  var isCompletingMission: Bool = false

  var canConfirmReceived: Bool {
    guard let mission else {
      return false
    }
    switch mission.status {
    case .inProgress, .deliveryCompleted:
      return true
    default:
      return false
    }
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
  private let updateMissionActionUseCase: UpdateMissionActionUseCase
  private let cancelProposalUseCase: CancelProposalUseCase
  private let userRepository: UserRepositoryProtocol

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    updateMissionActionUseCase: UpdateMissionActionUseCase,
    cancelProposalUseCase: CancelProposalUseCase,
    userRepository: UserRepositoryProtocol
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.updateMissionActionUseCase = updateMissionActionUseCase
    self.cancelProposalUseCase = cancelProposalUseCase
    self.userRepository = userRepository
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
        matchedRunnerProfile = try await userRepository.fetchRunnerProfile(userID: matchedOffer.runnerID)
      } else {
        matchedRunnerProfile = nil
      }
    } catch {
      errorMessage = "내 요청 상세를 불러오지 못했어요."
    }
    isLoading = false
  }

  /// 오더 수령 확인. `PUT /v1/mission/{id}` — `CONFIRM_RECEIVED`
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
