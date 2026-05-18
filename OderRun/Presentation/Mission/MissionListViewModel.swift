//
//  MissionListViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//
//  단일 역할(orderer 또는 runner) 미션 목록을 다루는 얇은 wrapper.
//  ActivityViewModel 처럼 두 역할을 한 화면에서 함께 노출할 때는 두 인스턴스를 합성해 사용한다.
//

import Foundation

@Observable
final class MissionListViewModel {
  let role: MissionRole

  var missions: [Mission] = []
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchMyActivitiesUseCase: FetchMyActivitiesUseCase

  init(role: MissionRole, fetchMyActivitiesUseCase: FetchMyActivitiesUseCase) {
    self.role = role
    self.fetchMyActivitiesUseCase = fetchMyActivitiesUseCase
  }

  @MainActor
  func load(status: MissionStatus? = nil) async {
    isLoading = true
    errorMessage = nil
    do {
      missions = try await fetchMyActivitiesUseCase.execute(role: role, status: status)
    } catch {
      errorMessage = "미션을 불러오지 못했어요."
    }
    isLoading = false
  }
}
