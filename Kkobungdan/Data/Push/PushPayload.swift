//
//  PushPayload.swift
//  Kkobungdan
//

import Foundation

/// FCM 푸시 `data` payload. (알림 정책 문서의 클라이언트 라우팅 계약)
/// 모든 값은 문자열로 온다: `{ "notification_type": "offer_accepted", "offer_id": "45", "proposal_id": "10" }`
struct PushPayload: Equatable {
  /// 정책 문서 "이벤트별 data payload" 의 `notification_type` 과 1:1.
  /// 알림 목록 API 의 `NotificationType`(서버 enum 15종) 과 달리, 푸시로 발송되는 이벤트만 담는다.
  enum EventType: String {
    /// 지원자 발생 (수신: 요청자)
    case offerNew = "offer_new"
    /// 지원 완료 (수신: 지원자 본인)
    case offerSubmitted = "offer_submitted"
    /// 지원 수락 (수신: 선택된 지원자)
    case offerAccepted = "offer_accepted"
    /// 탈락 통보 (수신: 탈락 지원자 전원)
    case offerRejected = "offer_rejected"
    /// 만남 확인 (수신: 상대방 — 요청자/지원자 양방향 동일 타입)
    case meetingConfirmed = "meeting_confirmed"
    /// 양측 확인 완료 (수신: 요청자 + 지원자)
    case executionCompleted = "execution_completed"
    /// 분쟁 접수 (수신: 상대방 — 요청자/지원자 양방향 동일 타입)
    case disputeRaised = "dispute_raised"
  }

  let type: EventType
  let offerID: Int64
  let proposalID: Int64
}

extension PushPayload {
  /// APNs `userInfo`(FCM data 필드가 최상위에 병합돼 들어온다)에서 파싱한다. 계약과 어긋나면 nil.
  init?(userInfo: [AnyHashable: Any]) {
    guard
      let rawType = userInfo["notification_type"] as? String,
      let type = EventType(rawValue: rawType),
      let offerID = (userInfo["offer_id"] as? String).flatMap(Int64.init),
      let proposalID = (userInfo["proposal_id"] as? String).flatMap(Int64.init)
    else {
      return nil
    }
    self.init(type: type, offerID: offerID, proposalID: proposalID)
  }
}
