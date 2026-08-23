//
//  NotificationStatus.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation
import OSLog

private let notificationStatusLogger = Logger(
  subsystem: "com.kkobungdan.Kkobungdan",
  category: "Notification"
)

/// 서버 알림의 FCM 발송 라이프사이클 상태.
enum NotificationStatus: String, Decodable, CaseIterable {
  /// 알림 생성됨, 아직 푸시 발송 전
  case pending
  /// FCM 발송 완료 (`sent_at` 기록)
  case sent
  /// 기기 수신 확인됨 (`delivered_at` 기록)
  case delivered
  /// FCM 발송 실패 (`error_message` 기록)
  case failed
  /// 사용자가 읽음 (`read_at` 기록)
  case read
  /// 푸시 발송 생략됨 — FCM 토큰 미등록 등으로 발송하지 않음 (`fcm_message_id`·`sent_at` 없음)
  case skipped

  /// 서버가 새 상태를 추가했을 때(구버전 앱) 목록 **전체** 디코딩이 실패하지 않도록 두는 센티널.
  /// 서버는 이 값을 보내지 않는다. 읽음 판정은 `.read` 만 보므로 안읽음으로 취급된다.
  case unknown = "__unknown__"

  init(from decoder: any Decoder) throws {
    let rawValue = try decoder.singleValueContainer().decode(String.self)
    if let known = NotificationStatus(rawValue: rawValue), known != .unknown {
      self = known
    } else {
      notificationStatusLogger.error("알 수 없는 notification status: \(rawValue, privacy: .public)")
      self = .unknown
    }
  }
}
