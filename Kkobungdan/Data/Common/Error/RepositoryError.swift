//
//  RepositoryError.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum RepositoryError: Error {
  case notImplemented
  case notFound
  case conflict
  case unauthorized
  case network
  /// 서버가 `ErrorResponse` 바디로 내려준 에러. `message` 는 사용자에게 그대로 노출 가능한 문구.
  case server(code: String, message: String)
}

extension Error {
  /// 서버가 내려준 에러 메시지가 있으면 그대로, 없으면 화면별 fallback 문구를 반환한다.
  func userMessage(fallback: String) -> String {
    if let repositoryError = self as? RepositoryError,
       case let .server(_, message) = repositoryError {
      return message
    }
    return fallback
  }

  /// 태스크 취소로 발생한 에러인지. `.task(id:)` 의 id 변경·화면 이탈로 진행 중이던 요청이
  /// 취소되면 URLSession 이 던지므로, 사용자에게 실패 토스트를 띄우면 안 된다.
  var isCancellation: Bool {
    self is CancellationError || (self as? URLError)?.code == .cancelled
  }

  /// 상태코드가 아니라 서버가 명시한 코드로 분기할 때 사용한다.
  func isServerError(_ code: ServerErrorCode) -> Bool {
    if let repositoryError = self as? RepositoryError,
       case let .server(serverCode, _) = repositoryError {
      return serverCode == code.rawValue
    }
    return false
  }
}
