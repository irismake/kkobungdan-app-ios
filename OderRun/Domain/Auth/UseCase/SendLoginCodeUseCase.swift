//
//  SendLoginCodeUseCase.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

struct SendLoginCodeUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(phone: String) async throws -> PhoneVerification {
    try await authRepository.sendLoginCode(phone: phone)
  }
}
