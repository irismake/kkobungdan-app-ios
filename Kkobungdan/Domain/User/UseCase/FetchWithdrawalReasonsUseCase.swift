//
//  FetchWithdrawalReasonsUseCase.swift
//  Kkobungdan
//
//  회원 탈퇴 사유 목록 조회(GET /v1/user/withdrawal-reasons).
//

import Foundation

struct FetchWithdrawalReasonsUseCase {
  private let userRepository: UserRepositoryProtocol

  init(userRepository: UserRepositoryProtocol) {
    self.userRepository = userRepository
  }

  func execute() async throws -> [WithdrawalReason] {
    try await userRepository.fetchWithdrawalReasons()
  }
}
