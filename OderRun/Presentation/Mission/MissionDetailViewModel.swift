//
//  MissionDetailViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//
//  특정 proposalID 에 대한 '내 미션' 을 추적하고 역할별 액션(START_PROGRESS / COMPLETE_DELIVERY /
//  CONFIRM_RECEIVED / DISPUTE) 호출을 담당한다. 더미 모드에서는 같은 DIContainer.missionRepository
//  싱글턴을 공유하므로 한 화면에서 발생한 변경이 다른 화면에도 즉시 반영된다.
//

import Foundation

@Observable
final class MissionDetailViewModel {
  let proposalID: Int64
  let role: MissionRole

  var mission: Mission?
  var isLoading: Bool = false
  var isUpdating: Bool = false
  var errorMessage: String?

  private let fetchMyActivitiesUseCase: FetchMyActivitiesUseCase
  private let updateMissionActionUseCase: UpdateMissionActionUseCase

  init(
    proposalID: Int64,
    role: MissionRole,
    fetchMyActivitiesUseCase: FetchMyActivitiesUseCase,
    updateMissionActionUseCase: UpdateMissionActionUseCase
  ) {
    self.proposalID = proposalID
    self.role = role
    self.fetchMyActivitiesUseCase = fetchMyActivitiesUseCase
    self.updateMissionActionUseCase = updateMissionActionUseCase
  }

  /// 역할 기반으로 현재 노출 가능한 액션. 액션이 없으면 화면에 버튼을 노출하지 않는다.
  var availableActions: [MissionAction] {
    guard let status = mission?.status else {
      return []
    }
    switch (role, status) {
    case (.runner, .created):
      return [.startProgress]
    case (.runner, .inProgress):
      return [.completeDelivery]
    case (.orderer, .deliveryCompleted):
      return [.confirmReceived, .dispute]
    default:
      return []
    }
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let missions = try await fetchMyActivitiesUseCase.execute(role: role)
      mission = missions.first(where: { $0.proposalID == proposalID })
    } catch {
      errorMessage = "미션 정보를 불러오지 못했어요."
    }
    isLoading = false
  }

  @MainActor
  func performAction(
    _ action: MissionAction,
    proofImageURL: String? = nil,
    disputeReason: String? = nil
  ) async {
    guard let current = mission, !isUpdating else {
      return
    }
    isUpdating = true
    errorMessage = nil
    do {
      let resolvedProof = proofImageURL ?? Self.defaultProofIfNeeded(for: action)
      mission = try await updateMissionActionUseCase.execute(
        id: current.id,
        action: action,
        proofImageURL: resolvedProof,
        disputeReason: disputeReason
      )
    } catch {
      errorMessage = "미션 상태 변경에 실패했어요."
    }
    isUpdating = false
  }

  /// COMPLETE_DELIVERY 는 더미 레포지토리에서 proofImageURL 을 요구한다.
  private static func defaultProofIfNeeded(for action: MissionAction) -> String? {
    action == .completeDelivery ? "https://cdn.orderrun.com/proofs/dummy.jpg" : nil
  }
}
