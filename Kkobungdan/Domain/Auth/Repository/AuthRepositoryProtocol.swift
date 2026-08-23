//
//  AuthRepositoryProtocol.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

protocol AuthRepositoryProtocol: Sendable {
  func sendSignupCode(name: String, phone: String, carrier: String) async throws -> PhoneVerification
  func confirmSignupCode(code: String, phone: String) async throws -> AuthTokens
  func sendLoginCode(phone: String) async throws -> PhoneVerification
  func confirmLoginCode(code: String, phone: String) async throws -> AuthTokens
  func signup(email: String, password: String, name: String, phone: String) async throws
  func refresh(refreshToken: String) async throws -> String
  func logout(refreshToken: String) async throws
}
