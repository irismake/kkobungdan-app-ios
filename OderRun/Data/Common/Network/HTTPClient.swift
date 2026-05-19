//
//  HTTPClient.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

final class HTTPClient {
  static let shared = HTTPClient(tokenStorage: .shared)

  private static let baseURL: String = {
    guard let host = Bundle.main.object(forInfoDictionaryKey: "API_BASE_HOST") as? String,
          !host.isEmpty
    else {
      fatalError("API_BASE_HOST 가 Info.plist 에 없습니다. Secrets.xcconfig 설정을 확인하세요.")
    }
    return "http://\(host)"
  }()

  private static let refreshPath = "/v1/auth/refresh"

  private let session: URLSession
  private let tokenStorage: TokenStorage
  private let tokenRefresher: TokenRefreshHandler

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  init(tokenStorage: TokenStorage, session: URLSession = .shared) {
    self.tokenStorage = tokenStorage
    self.session = session
    tokenRefresher = TokenRefreshHandler(
      tokenStorage: tokenStorage,
      baseURL: Self.baseURL,
      session: session
    )
  }

  // MARK: - Public Methods

  func get<T: Decodable>(_ path: String, params: [String: Any] = [:]) async throws -> T {
    let request = try buildRequest(method: "GET", path: path, params: params, body: nil as String?)
    return try await perform(request, isRetry: false)
  }

  func post<T: Decodable, B: Encodable>(_ path: String, body: B? = nil as String?) async throws -> T {
    let request = try buildRequest(method: "POST", path: path, params: [:], body: body)
    return try await perform(request, isRetry: false)
  }

  func put<T: Decodable, B: Encodable>(_ path: String, body: B? = nil as String?) async throws -> T {
    let request = try buildRequest(method: "PUT", path: path, params: [:], body: body)
    return try await perform(request, isRetry: false)
  }

  func delete(_ path: String) async throws {
    let request = try buildRequest(method: "DELETE", path: path, params: [:], body: nil as String?)
    try await performVoid(request, isRetry: false)
  }

  // MARK: - Private Helpers

  private func buildRequest<B: Encodable>(
    method: String,
    path: String,
    params: [String: Any],
    body: B?
  ) throws -> URLRequest {
    var components = URLComponents(string: Self.baseURL + path)!
    if !params.isEmpty {
      components.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
    var request = URLRequest(url: components.url!)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = tokenStorage.accessToken {
      request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    if let body {
      request.httpBody = try JSONEncoder().encode(body)
    }
    return request
  }

  private func perform<T: Decodable>(_ request: URLRequest, isRetry: Bool) async throws -> T {
    let (data, response) = try await session.data(for: request)

    if try await shouldRetryAfterRefresh(request: request, response: response, isRetry: isRetry) {
      return try await perform(rebuiltRequest(from: request), isRetry: true)
    }

    try mapHTTPError(response: response)
    do {
      let envelope = try decoder.decode(ApiResponseDTO<T>.self, from: data)
      guard let data = envelope.data else {
        throw RepositoryError.network
      }
      return data
    } catch let error as RepositoryError {
      throw error
    } catch {
      throw RepositoryError.network
    }
  }

  private func performVoid(_ request: URLRequest, isRetry: Bool) async throws {
    let (_, response) = try await session.data(for: request)

    if try await shouldRetryAfterRefresh(request: request, response: response, isRetry: isRetry) {
      try await performVoid(rebuiltRequest(from: request), isRetry: true)
      return
    }

    try mapHTTPError(response: response)
  }

  /// 401 응답을 받았을 때 refresh 를 시도하고, 호출자가 동일 요청을 재시도해야 하는지 반환한다.
  /// refresh 자체가 실패하면 토큰을 클리어하고 unauthorized 를 throw 한다.
  private func shouldRetryAfterRefresh(
    request: URLRequest,
    response: URLResponse,
    isRetry: Bool
  ) async throws -> Bool {
    guard let http = response as? HTTPURLResponse, http.statusCode == 401 else {
      return false
    }
    // 이미 한 번 재시도했는데도 401 — refresh 로 회복 불가
    if isRetry {
      tokenStorage.clear()
      throw RepositoryError.unauthorized
    }
    // refresh 엔드포인트 자체의 401 은 정상 경로(mapHTTPError)로 처리
    guard request.url?.path != Self.refreshPath else {
      return false
    }
    // 애초에 Authorization 헤더 없이 보낸 요청은 refresh 대상이 아님
    guard let auth = request.value(forHTTPHeaderField: "Authorization") else {
      return false
    }

    let currentToken = auth.hasPrefix("Bearer ") ? String(auth.dropFirst("Bearer ".count)) : auth
    do {
      _ = try await tokenRefresher.refresh(currentAccessToken: currentToken)
      return true
    } catch {
      tokenStorage.clear()
      throw RepositoryError.unauthorized
    }
  }

  private func rebuiltRequest(from request: URLRequest) -> URLRequest {
    var retry = request
    if let token = tokenStorage.accessToken {
      retry.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
    return retry
  }

  private func mapHTTPError(response: URLResponse) throws {
    guard let http = response as? HTTPURLResponse else {
      return
    }
    switch http.statusCode {
    case 200 ..< 300: return
    case 401: throw RepositoryError.unauthorized
    case 404: throw RepositoryError.notFound
    case 409: throw RepositoryError.conflict
    default: throw RepositoryError.network
    }
  }
}
