//
//  ConfirmLoginCodeUseCase.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

struct ConfirmLoginCodeUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(code: String, phone: String) async throws -> AuthTokens {
    try await authRepository.confirmLoginCode(code: code, phone: phone)
  }
}
