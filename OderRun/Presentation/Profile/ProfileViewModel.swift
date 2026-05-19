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
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchUserDetailUseCase: FetchUserDetailUseCase
  private let updateAlarmUseCase: UpdateAlarmUseCase
  private let logoutUseCase: LogoutUseCase
  private let tokenStorage: TokenStorage
  private let onLogout: () -> Void

  init(
    fetchUserDetailUseCase: FetchUserDetailUseCase,
    updateAlarmUseCase: UpdateAlarmUseCase,
    logoutUseCase: LogoutUseCase,
    tokenStorage: TokenStorage = .shared,
    onLogout: @escaping () -> Void = {}
  ) {
    self.fetchUserDetailUseCase = fetchUserDetailUseCase
    self.updateAlarmUseCase = updateAlarmUseCase
    self.logoutUseCase = logoutUseCase
    self.tokenStorage = tokenStorage
    self.onLogout = onLogout
  }

  static func preview() -> ProfileViewModel {
    let userRepo = DIContainer.userRepository
    let viewModel = ProfileViewModel(
      fetchUserDetailUseCase: FetchUserDetailUseCase(userRepository: userRepo),
      updateAlarmUseCase: UpdateAlarmUseCase(userRepository: userRepo),
      logoutUseCase: LogoutUseCase(authRepository: DIContainer.authRepository)
    )
    viewModel.user = User.dummy
    return viewModel
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      user = try await fetchUserDetailUseCase.execute()
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

  @MainActor
  func logout() async {
    guard !isLoading else { return }
    isLoading = true
    errorMessage = nil
    let refreshToken = tokenStorage.refreshToken ?? ""
    do {
      try await logoutUseCase.execute(refreshToken: refreshToken)
      onLogout()
    } catch {
      errorMessage = "로그아웃에 실패했어요."
    }
    isLoading = false
  }
}
