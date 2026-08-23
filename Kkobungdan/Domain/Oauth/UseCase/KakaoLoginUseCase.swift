//
//  KakaoLoginUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/12/26.
//

import Foundation

struct KakaoLoginUseCase {
  private let oauthRepository: OauthRepositoryProtocol

  init(oauthRepository: OauthRepositoryProtocol) {
    self.oauthRepository = oauthRepository
  }

  func execute(accessToken: String) async throws -> KakaoLoginResult {
    try await oauthRepository.loginWithKakao(accessToken: accessToken)
  }
}
