//
//  AppleLoginUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/11/26.
//

import Foundation

struct AppleLoginUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(authorizationCode: String, userName: String?) async throws -> AppleLoginResult {
    try await authRepository.loginWithApple(authorizationCode: authorizationCode, userName: userName)
  }
}
