//
//  UserRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

protocol UserRepositoryProtocol: Sendable {
  func fetchUserDetail() async throws -> User
  func updateName(_ name: String) async throws -> User
  func updateAlarm(enabled: Bool) async throws -> User
  func updateFcmToken(_ token: String) async throws
}
