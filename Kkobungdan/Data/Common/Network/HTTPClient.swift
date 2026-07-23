//
//  HTTPClient.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog

private let networkLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Network")

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

  /// envelope 의 `data` 가 없을 수 있는 조회(예: 정산 계좌 미등록 시 `{success, message}` 만 반환) 전용.
  func getOptional<T: Decodable>(_ path: String, params: [String: Any] = [:]) async throws -> T? {
    let request = try buildRequest(method: "GET", path: path, params: params, body: nil as String?)
    return try await performOptional(request, isRetry: false)
  }

  func post<T: Decodable, B: Encodable>(_ path: String, body: B? = nil as String?) async throws -> T {
    let request = try buildRequest(method: "POST", path: path, params: [:], body: body)
    return try await perform(request, isRetry: false)
  }

  func put<T: Decodable, B: Encodable>(_ path: String, body: B? = nil as String?) async throws -> T {
    let request = try buildRequest(method: "PUT", path: path, params: [:], body: body)
    return try await perform(request, isRetry: false)
  }

  func postVoid<B: Encodable>(_ path: String, body: B? = nil as String?) async throws {
    let request = try buildRequest(method: "POST", path: path, params: [:], body: body)
    try await performVoid(request, isRetry: false)
  }

  func patchVoid<B: Encodable>(_ path: String, body: B? = nil as String?) async throws {
    let request = try buildRequest(method: "PATCH", path: path, params: [:], body: body)
    try await performVoid(request, isRetry: false)
  }

  func delete<B: Encodable>(_ path: String, body: B? = nil as String?) async throws {
    let request = try buildRequest(method: "DELETE", path: path, params: [:], body: body)
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
      // 배열 값은 같은 키를 반복해 다중값 쿼리(`status=A&status=B`)로 직렬화한다.
      components.queryItems = params.flatMap { key, value -> [URLQueryItem] in
        if let array = value as? [Any] {
          return array.map { URLQueryItem(name: key, value: "\($0)") }
        }
        return [URLQueryItem(name: key, value: "\(value)")]
      }
    }
    var request = URLRequest(url: components.url!)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    if let token = tokenStorage.accessToken {
      let scheme = tokenStorage.tokenType ?? "Bearer"
      request.setValue("\(scheme) \(token)", forHTTPHeaderField: "Authorization")
    }
    if let body {
      request.httpBody = try JSONEncoder().encode(body)
    }
    return request
  }

  /// 요청 전송 → 로깅 → 401 refresh 재시도 → 상태코드 매핑까지 처리하고 본문 `Data` 를 반환한다.
  /// 디코딩은 각 호출자(`perform`/`performOptional`)에서 분기한다.
  private func sendAndValidate(_ request: URLRequest, isRetry: Bool) async throws -> Data {
    let method = request.httpMethod ?? "?"
    let url = request.url?.absoluteString ?? "?"
    if let body = request.httpBody, let bodyStr = String(data: body, encoding: .utf8) {
      networkLogger.debug("→ \(method) \(url)\n\(bodyStr)")
    } else {
      networkLogger.debug("→ \(method) \(url)")
    }

    let (data, response) = try await session.data(for: request)

    if let http = response as? HTTPURLResponse {
      let bodyStr = String(data: data, encoding: .utf8) ?? "(binary)"
      if (200 ..< 300).contains(http.statusCode) {
        networkLogger.debug("← \(http.statusCode) \(url)\n\(bodyStr)")
      } else {
        networkLogger.error("← \(http.statusCode) \(url)\n\(bodyStr)")
      }
    }

    if try await shouldRetryAfterRefresh(request: request, response: response, isRetry: isRetry) {
      return try await sendAndValidate(rebuiltRequest(from: request), isRetry: true)
    }

    try mapHTTPError(response: response, data: data)
    return data
  }

  private func perform<T: Decodable>(_ request: URLRequest, isRetry: Bool) async throws -> T {
    let data = try await sendAndValidate(request, isRetry: isRetry)
    do {
      let envelope = try decoder.decode(ApiResponseDTO<T>.self, from: data)
      guard let payload = envelope.data else {
        throw RepositoryError.network
      }
      return payload
    } catch let error as RepositoryError {
      throw error
    } catch {
      throw RepositoryError.network
    }
  }

  /// envelope 의 `data` 가 없으면 `nil` 을 반환한다(에러로 보지 않음).
  private func performOptional<T: Decodable>(_ request: URLRequest, isRetry: Bool) async throws -> T? {
    let data = try await sendAndValidate(request, isRetry: isRetry)
    do {
      let envelope = try decoder.decode(ApiResponseDTO<T>.self, from: data)
      return envelope.data
    } catch {
      throw RepositoryError.network
    }
  }

  private func performVoid(_ request: URLRequest, isRetry: Bool) async throws {
    _ = try await sendAndValidate(request, isRetry: isRetry)
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
      tokenStorage.forceLogout()
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

    // "<scheme> <token>" 에서 토큰만 추출 (scheme 은 Bearer 등 가변).
    let currentToken = auth.split(separator: " ", maxSplits: 1).last.map(String.init) ?? auth
    do {
      _ = try await tokenRefresher.refresh(currentAccessToken: currentToken)
      return true
    } catch {
      tokenStorage.forceLogout()
      throw RepositoryError.unauthorized
    }
  }

  private func rebuiltRequest(from request: URLRequest) -> URLRequest {
    var retry = request
    if let token = tokenStorage.accessToken {
      let scheme = tokenStorage.tokenType ?? "Bearer"
      retry.setValue("\(scheme) \(token)", forHTTPHeaderField: "Authorization")
    }
    return retry
  }

  private func mapHTTPError(response: URLResponse, data: Data) throws {
    guard let http = response as? HTTPURLResponse else {
      return
    }
    guard !(200 ..< 300).contains(http.statusCode) else {
      return
    }
    if let errorBody = try? decoder.decode(ApiErrorDTO.self, from: data) {
      throw RepositoryError.server(code: errorBody.error.code, message: errorBody.error.message)
    }
    switch http.statusCode {
    case 401: throw RepositoryError.unauthorized
    case 404: throw RepositoryError.notFound
    case 409: throw RepositoryError.conflict
    default: throw RepositoryError.network
    }
  }
}
