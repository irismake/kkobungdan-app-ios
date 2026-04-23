//
//  LoginUseCase.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

struct LoginUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(email: String, password: String) async throws -> AuthTokens {
    try await authRepository.login(email: email, password: password)
  }
}
