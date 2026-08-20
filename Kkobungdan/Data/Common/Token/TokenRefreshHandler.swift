//
//  TokenRefreshHandler.swift
//  Kkobungdan
//

import Foundation
import OSLog

private let authLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Auth")

/// `RefreshTokenUseCase` 호출을 직렬화한다.
/// 여러 요청이 동시에 401을 받아도 refresh 는 한 번만 수행되고, 나머지는 같은 결과를 await 한다.
actor TokenRefreshHandler {
  private let tokenStorage: TokenStorage
  private let makeRefreshTokenUseCase: @Sendable () -> RefreshTokenUseCase
  private var inflightTask: Task<String, Error>?
  private lazy var refreshTokenUseCase: RefreshTokenUseCase = makeRefreshTokenUseCase()

  init(
    tokenStorage: TokenStorage,
    refreshTokenUseCase: @escaping @Sendable () -> RefreshTokenUseCase = {
      RefreshTokenUseCase(authRepository: DIContainer.authRepository)
    }
  ) {
    self.tokenStorage = tokenStorage
    makeRefreshTokenUseCase = refreshTokenUseCase
  }

  /// 401을 받은 호출자가 가지고 있던 access token 을 넘기면, 그 사이 다른 요청이
  /// 이미 refresh 를 끝냈는지 확인하고 — 아니면 직접 refresh 하고 — 새 access token 을 돌려준다.
  func refresh(currentAccessToken: String?) async throws -> String {
    if let stored = tokenStorage.accessToken, stored != currentAccessToken {
      return stored
    }

    if let task = inflightTask {
      return try await task.value
    }

    let task = Task<String, Error> {
      try await self.performRefresh()
    }
    inflightTask = task

    do {
      let token = try await task.value
      inflightTask = nil
      return token
    } catch {
      inflightTask = nil
      throw error
    }
  }

  private func performRefresh() async throws -> String {
    guard let refreshToken = tokenStorage.refreshToken else {
      throw RepositoryError.unauthorized
    }
    do {
      return try await refreshTokenUseCase.execute(refreshToken: refreshToken)
    } catch {
      throw sessionFailure(from: error)
    }
  }

  private func sessionFailure(from error: Error) -> Error {
    switch (error.isServerError(.invalidToken), error.isServerError(.userNotFound)) {
    case (true, _), (_, true):
      authLogger.error("토큰 갱신 실패 — 세션 복구 불가: \(String(describing: error))")
      return RepositoryError.unauthorized
    default:
      authLogger.warning("토큰 갱신 실패 — 세션 유지: \(String(describing: error))")
      return error
    }
  }
}
