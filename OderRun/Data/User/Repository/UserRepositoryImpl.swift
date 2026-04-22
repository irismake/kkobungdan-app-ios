//
//  UserRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

final class UserRepositoryImpl: UserRepositoryProtocol, Sendable {
  func fetchUserDetail() async throws -> User {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }

  func updateAlarm(enabled _: Bool) async throws -> User {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }

  func fetchRunnerProfile(userID _: String) async throws -> RunnerProfile {
    // TODO: Step 4 에서 seed 채움
    throw RepositoryError.notImplemented
  }
}
