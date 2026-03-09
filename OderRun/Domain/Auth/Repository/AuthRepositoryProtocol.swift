//
//  AuthRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import Foundation

protocol AuthRepositoryProtocol: Sendable {
  func login(email: String, password: String) async throws -> User
}
