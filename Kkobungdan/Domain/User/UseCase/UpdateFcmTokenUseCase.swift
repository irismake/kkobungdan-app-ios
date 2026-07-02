//
//  UpdateFcmTokenUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

struct UpdateFcmTokenUseCase {
  private let userRepository: UserRepositoryProtocol

  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }

  func execute(token: String) async throws {
    try await userRepository.updateFcmToken(token)
  }
}
