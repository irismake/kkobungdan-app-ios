//
//  EmailLoginUseCase.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

struct EmailLoginUseCase {
  private let oauthRepository: OauthRepositoryProtocol

  init(oauthRepository: OauthRepositoryProtocol) {
    self.oauthRepository = oauthRepository
  }

  func execute(email: String, password: String) async throws -> AuthTokens {
    try await oauthRepository.emailLogin(email: email, password: password)
  }
}
