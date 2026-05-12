//
//  KakaoLoginUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/12/26.
//

import Foundation

struct KakaoLoginUseCase {
  private let authRepository: AuthRepositoryProtocol

  init(authRepository: AuthRepositoryProtocol) {
    self.authRepository = authRepository
  }

  func execute(accessToken: String) async throws -> KakaoLoginResult {
    try await authRepository.loginWithKakao(accessToken: accessToken)
  }
}
