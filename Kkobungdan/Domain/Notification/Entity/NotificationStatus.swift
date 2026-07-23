//
//  NotificationStatus.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

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
}
