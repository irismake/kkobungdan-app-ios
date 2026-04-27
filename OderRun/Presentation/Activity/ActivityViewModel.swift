//
//  ActivityViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//
//  '내 활동' 탭의 데이터 소스. 의뢰자(orderer) / 러너(runner) 역할별로
//  진행 중인 미션을 가져오고, 각 미션의 proposal 정보를 함께 묶어 화면에 노출한다.
//

import Foundation

struct ActivityMissionItem: Identifiable, Equatable {
  let mission: Mission
  let proposal: Proposal?

  var id: Int64 {
    mission.id
  }
}

@Observable
final class ActivityViewModel {
  var ordererMissions: [ActivityMissionItem] = []
  var runnerMissions: [ActivityMissionItem] = []
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchMyMissionsUseCase: FetchMyMissionsUseCase
  private let proposalRepository: ProposalRepositoryProtocol

  init(
    fetchMyMissionsUseCase: FetchMyMissionsUseCase,
    proposalRepository: ProposalRepositoryProtocol
  ) {
    self.fetchMyMissionsUseCase = fetchMyMissionsUseCase
    self.proposalRepository = proposalRepository
  }

  static func preview() -> ActivityViewModel {
    ActivityViewModel(
      fetchMyMissionsUseCase: FetchMyMissionsUseCase(repository: DIContainer.missionRepository),
      proposalRepository: DIContainer.proposalRepository
    )
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let ordererTask = fetchMyMissionsUseCase.execute(role: .orderer)
      async let runnerTask = fetchMyMissionsUseCase.execute(role: .runner)
      let (orderer, runner) = try await (ordererTask, runnerTask)
      ordererMissions = await Self.attachProposals(to: orderer, repository: proposalRepository)
      runnerMissions = await Self.attachProposals(to: runner, repository: proposalRepository)
    } catch {
      errorMessage = "내 활동을 불러오지 못했어요."
    }
    isLoading = false
  }

  /// 더미 모드에서는 proposalID 가 0/999 같이 매칭 안되는 케이스가 있어 nil 허용
  private static func attachProposals(
    to missions: [Mission],
    repository: ProposalRepositoryProtocol
  ) async -> [ActivityMissionItem] {
    var items: [ActivityMissionItem] = []
    for mission in missions {
      let proposal = try? await repository.fetchProposal(id: mission.proposalID)
      items.append(ActivityMissionItem(mission: mission, proposal: proposal))
    }
    return items
  }
}
