//
//  LogoutUseCase.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct LogoutUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(refreshToken: String) async throws {
    try await authRepository.logout(refreshToken: refreshToken)
  }
}
