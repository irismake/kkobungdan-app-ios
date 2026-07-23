//
//  WithdrawUserUseCase.swift
//  Kkobungdan
//
//  회원 탈퇴(DELETE /v1/user).
//

import Foundation

struct WithdrawUserUseCase {
  private let userRepository: UserRepositoryProtocol

  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }

  func execute() async throws {
    try await userRepository.withdraw()
  }
}
