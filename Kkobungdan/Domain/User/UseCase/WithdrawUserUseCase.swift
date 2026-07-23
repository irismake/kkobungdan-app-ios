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

  func execute(reasonQuestionID: Int64?, detailReason: String?) async throws {
    try await userRepository.withdraw(
      reasonQuestionID: reasonQuestionID,
      detailReason: detailReason
    )
  }
}
