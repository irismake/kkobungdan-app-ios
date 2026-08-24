//
//  RepositoryError.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog

private let errorLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Network")

enum RepositoryError: Error {
  case notImplemented
  case notFound
  case conflict
  case unauthorized
  case rateLimited
  case network
  /// 서버가 `ErrorResponse` 바디로 내려준 에러. `message` 는 사용자에게 그대로 노출 가능한 문구.
  case server(code: ServerErrorCode, message: String)
}

extension Error {
  /// 서버가 내려준 에러 메시지가 있으면 그대로, 없으면 화면별 fallback 문구를 반환한다.
  func userMessage(fallback: String) -> String {
    guard let repositoryError = self as? RepositoryError else {
      return fallback
    }
    switch repositoryError {
    case let .server(code, message):
      // 미등록 코드(구버전 앱)·카탈로그 우회 예외는 서버 문구가 일반적이라 화면별 fallback 이 더 구체적이다.
      if code == .unknown || code == .httpError {
        errorLogger.error("일반 오류로 처리한 서버 에러 코드: \(code.rawValue) \(message)")
        return fallback
      }
      if code.isClientBugSignal {
        errorLogger.fault("잘못된 요청 — 클라이언트 버그: \(code.rawValue) \(message)")
        return fallback
      }
      return message
    case .rateLimited:
      return "요청이 너무 많습니다. 잠시 후 다시 시도해주세요."
    default:
      return fallback
    }
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
      return serverCode == code
    }
    return false
  }
}
