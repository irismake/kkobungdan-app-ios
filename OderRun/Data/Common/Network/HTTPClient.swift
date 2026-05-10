//
//  HTTPClient.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

final class HTTPClient {
  static let shared = HTTPClient(tokenStorage: .shared)

  private let baseURL = "http://43.200.56.9"
  private let session: URLSession
  private let tokenStorage: TokenStorage

  private let decoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
  }()

  init(tokenStorage: TokenStorage, session: URLSession = .shared) {
    self.tokenStorage = tokenStorage
    self.session = session
  }

  // MARK: - Public Methods

  func get<T: Decodable>(_ path: String, params: [String: Any] = [:]) async throws -> T {
    let request = try buildRequest(method: "GET", path: path, params: params, body: nil as String?)
    return try await perform(request)
  }

  func post<T: Decodable, B: Encodable>(_ path: String, body: B? = nil as String?) async throws -> T {
    let request = try buildRequest(method: "POST", path: path, params: [:], body: body)
    return try await perform(request)
  }

  func put<T: Decodable, B: Encodable>(_ path: String, body: B? = nil as String?) async throws -> T {
    let request = try buildRequest(method: "PUT", path: path, params: [:], body: body)
    return try await perform(request)
  }

  func delete(_ path: String) async throws {
    let request = try buildRequest(method: "DELETE", path: path, params: [:], body: nil as String?)
    let (_, response) = try await session.data(for: request)
    try mapHTTPError(response: response)
  }

  // MARK: - Private Helpers

  private func buildRequest<B: Encodable>(
    method: String,
    path: String,
    params: [String: Any],
    body: B?
  ) throws -> URLRequest {
    var components = URLComponents(string: baseURL + path)!
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

  private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
    let (data, response) = try await session.data(for: request)
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
