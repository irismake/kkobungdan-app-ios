//
//  FetchUserDetailUseCase.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct FetchUserDetailUseCase {
  private let userRepository: UserRepositoryProtocol

  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }

  func execute() async throws -> User {
    try await userRepository.fetchUserDetail()
  }
}
