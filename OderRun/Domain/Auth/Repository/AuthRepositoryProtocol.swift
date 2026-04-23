//
//  AuthRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

protocol AuthRepositoryProtocol: Sendable {
  func signup(email: String, password: String, name: String, phone: String) async throws
  func login(email: String, password: String) async throws -> AuthTokens
  func refresh(refreshToken: String) async throws -> AuthTokens
  func logout(refreshToken: String) async throws
}
