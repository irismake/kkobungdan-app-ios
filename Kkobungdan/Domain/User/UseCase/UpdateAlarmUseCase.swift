//
//  UpdateAlarmUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct UpdateAlarmUseCase {
  private let userRepository: UserRepositoryProtocol

  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }

  func execute(enabled: Bool) async throws -> User {
    try await userRepository.updateAlarm(enabled: enabled)
  }
}
