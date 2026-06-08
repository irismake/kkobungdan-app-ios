//
//  SendSignupCodeUseCase.swift
//  OderRun
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

struct SendSignupCodeUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(name: String, phone: String, carrier: String) async throws -> PhoneVerification {
    try await authRepository.sendSignupCode(name: name, phone: phone, carrier: carrier)
  }
}
