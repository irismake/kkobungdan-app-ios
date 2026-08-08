//
//  LoadableViewModel.swift
//  Kkobungdan
//
//

import Foundation

protocol LoadableViewModel: AnyObject {
  var isLoading: Bool { get set }
  var errorMessage: String? { get set }
}

extension LoadableViewModel {
  /// 취소는 오류로 노출하지 않고, 그 외 오류는 사용자 메시지로 변환한다.
  func withLoading(
    fallback: String,
    onFailure: ((Error) -> Void)? = nil,
    operation: () async throws -> Void
  ) async {
    isLoading = true
    errorMessage = nil
    defer { isLoading = false }
    do {
      try await operation()
    } catch {
      guard !error.isCancellation else {
        return
      }
      errorMessage = error.userMessage(fallback: fallback)
      onFailure?(error)
    }
  }
}
