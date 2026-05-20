//
//  TokenRefreshHandler.swift
//  OderRun
//

import Foundation

/// `/v1/auth/refresh` 호출을 직렬화한다.
/// 여러 요청이 동시에 401을 받아도 refresh 는 한 번만 수행되고, 나머지는 같은 결과를 await 한다.
actor TokenRefreshHandler {
  private let tokenStorage: TokenStorage
  private let baseURL: String
  private let session: URLSession
  private var inflightTask: Task<String, Error>?

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  init(tokenStorage: TokenStorage, baseURL: String, session: URLSession) {
    self.tokenStorage = tokenStorage
    self.baseURL = baseURL
    self.session = session
  }

  /// 401을 받은 호출자가 가지고 있던 access token 을 넘기면, 그 사이 다른 요청이
  /// 이미 refresh 를 끝냈는지 확인하고 — 아니면 직접 refresh 하고 — 새 access token 을 돌려준다.
  func refresh(currentAccessToken: String?) async throws -> String {
    if let stored = tokenStorage.accessToken, stored != currentAccessToken {
      return stored
    }

    if let task = inflightTask {
      return try await task.value
    }

    let task = Task<String, Error> {
      try await self.performRefresh()
    }
    inflightTask = task

    do {
      let token = try await task.value
      inflightTask = nil
      return token
    } catch {
      inflightTask = nil
      throw error
    }
  }

  private func performRefresh() async throws -> String {
    guard let refreshToken = tokenStorage.refreshToken else {
      throw RepositoryError.unauthorized
    }

    var request = URLRequest(url: URL(string: baseURL + "/v1/auth/refresh")!)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONSerialization.data(
      withJSONObject: ["refreshToken": refreshToken]
    )

    let (data, response) = try await session.data(for: request)
    guard let http = response as? HTTPURLResponse else {
      throw RepositoryError.network
    }
    if http.statusCode == 401 {
      throw RepositoryError.unauthorized
    }
    guard (200 ..< 300).contains(http.statusCode) else {
      throw RepositoryError.network
    }

    let envelope = try decoder.decode(ApiResponseDTO<LoginResponseDTO>.self, from: data)
    guard let tokens = envelope.data else {
      throw RepositoryError.network
    }
    tokenStorage.accessToken = tokens.accessToken
    tokenStorage.refreshToken = tokens.refreshToken
    return tokens.accessToken
  }
}
