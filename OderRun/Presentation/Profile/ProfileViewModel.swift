//
//  ProfileViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class ProfileViewModel {
  var user: User?
  var runnerProfile: RunnerProfile?
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchUserDetailUseCase: FetchUserDetailUseCase
  private let updateAlarmUseCase: UpdateAlarmUseCase
  private let userRepository: UserRepositoryProtocol

  init(
    fetchUserDetailUseCase: FetchUserDetailUseCase,
    updateAlarmUseCase: UpdateAlarmUseCase,
    userRepository: UserRepositoryProtocol
  ) {
    self.fetchUserDetailUseCase = fetchUserDetailUseCase
    self.updateAlarmUseCase = updateAlarmUseCase
    self.userRepository = userRepository
  }

  static func preview() -> ProfileViewModel {
    let repo = UserRepositoryImpl()
    let vm = ProfileViewModel(
      fetchUserDetailUseCase: FetchUserDetailUseCase(userRepository: repo),
      updateAlarmUseCase: UpdateAlarmUseCase(userRepository: repo),
      userRepository: repo
    )
    vm.user = .dummy
    vm.runnerProfile = .dummy
    return vm
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let user = try await fetchUserDetailUseCase.execute()
      self.user = user
      runnerProfile = try await userRepository.fetchRunnerProfile(userID: user.id)
    } catch {
      errorMessage = "프로필을 불러오지 못했어요."
    }
    isLoading = false
  }

  @MainActor
  func toggleAlarm(_ enabled: Bool) async {
    do {
      user = try await updateAlarmUseCase.execute(enabled: enabled)
    } catch {
      errorMessage = "알림 설정을 변경하지 못했어요."
    }
  }
}
