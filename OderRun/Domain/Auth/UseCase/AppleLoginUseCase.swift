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

  func execute(identityToken: String, name: String?, email: String?) async throws -> AppleLoginResult {
    try await authRepository.loginWithApple(identityToken: identityToken, name: name, email: email)
  }
}
