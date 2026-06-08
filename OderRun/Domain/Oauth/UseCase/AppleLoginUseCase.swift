//
//  AppleLoginUseCase.swift
//  OderRun
//
//  Created by 김가희 on 5/11/26.
//

import Foundation

struct AppleLoginUseCase {
  private let oauthRepository: OauthRepositoryProtocol

  init(oauthRepository: OauthRepositoryProtocol) {
    self.oauthRepository = oauthRepository
  }

  func execute(identityToken: String, name: String?, email: String?) async throws -> AppleLoginResult {
    try await oauthRepository.loginWithApple(identityToken: identityToken, name: name, email: email)
  }
}
