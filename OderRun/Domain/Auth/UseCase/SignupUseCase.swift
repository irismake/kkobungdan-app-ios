//
//  SignupUseCase.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct SignupUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(email: String, password: String, name: String, phone: String) async throws {
    try await authRepository.signup(email: email, password: password, name: name, phone: phone)
  }
}
