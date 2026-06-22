//
//  UpdateUserNameUseCase.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

struct UpdateUserNameUseCase {
  private let userRepository: UserRepositoryProtocol

  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }

  func execute(name: String) async throws -> User {
    try await userRepository.updateName(name)
  }
}
