//
//  ProfileViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog

private let profileLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Profile")

@Observable
final class ProfileViewModel: LoadableViewModel {
  var user: User?
  var isLoading: Bool = false
  var errorMessage: String?
  var didLogout: Bool = false

  private let fetchUserDetailUseCase: FetchUserDetailUseCase
  private let updateAlarmUseCase: UpdateAlarmUseCase
  private let updateUserNameUseCase: UpdateUserNameUseCase
  private let logoutUseCase: LogoutUseCase
  private let tokenStorage: TokenStorage

  init(
    fetchUserDetailUseCase: FetchUserDetailUseCase,
    updateAlarmUseCase: UpdateAlarmUseCase,
    updateUserNameUseCase: UpdateUserNameUseCase,
    logoutUseCase: LogoutUseCase,
    tokenStorage: TokenStorage = .shared
  ) {
    self.fetchUserDetailUseCase = fetchUserDetailUseCase
    self.updateAlarmUseCase = updateAlarmUseCase
    self.updateUserNameUseCase = updateUserNameUseCase
    self.logoutUseCase = logoutUseCase
    self.tokenStorage = tokenStorage
  }

  @MainActor
  func load() async {
    await withLoading(fallback: "프로필을 불러오지 못했어요.") {
      user = try await fetchUserDetailUseCase.execute()
    }
  }

  @MainActor
  func toggleAlarm(_ enabled: Bool) async {
    do {
      user = try await updateAlarmUseCase.execute(enabled: enabled)
    } catch {
      errorMessage = error.userMessage(fallback: "알림 설정을 변경하지 못했어요.")
    }
  }

  @MainActor
  func updateName(_ name: String) async {
    do {
      user = try await updateUserNameUseCase.execute(name: name)
    } catch {
      errorMessage = error.userMessage(fallback: "닉네임을 변경하지 못했어요.")
    }
  }

  @MainActor
  func logout() async {
    guard !isLoading else {
      return
    }
    isLoading = true
    errorMessage = nil
    let refreshToken = tokenStorage.refreshToken ?? ""
    do {
      try await logoutUseCase.execute(refreshToken: refreshToken)
    } catch {
      // 서버 로그아웃 실패해도 강제 로그아웃 진행 — 로컬 토큰을 정리하고 로그인 화면으로 복귀한다.
      tokenStorage.clear()
      profileLogger.warning("로그아웃 처리 실패, 강제 로그아웃 진행: \(error.localizedDescription)")
    }
    didLogout = true
    isLoading = false
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension ProfileViewModel {
  static func preview() -> ProfileViewModel {
    let userRepo = DIContainer.userRepository
    let viewModel = ProfileViewModel(
      fetchUserDetailUseCase: FetchUserDetailUseCase(userRepository: userRepo),
      updateAlarmUseCase: UpdateAlarmUseCase(userRepository: userRepo),
      updateUserNameUseCase: UpdateUserNameUseCase(userRepository: userRepo),
      logoutUseCase: LogoutUseCase(authRepository: DIContainer.authRepository)
    )
    viewModel.user = User.dummy
    return viewModel
  }
}
