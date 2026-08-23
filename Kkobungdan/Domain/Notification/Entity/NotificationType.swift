//
//  NotificationType.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation
import OSLog

private let notificationTypeLogger = Logger(
  subsystem: "com.kkobungdan.Kkobungdan",
  category: "Notification"
)

enum NotificationType: String, Decodable, CaseIterable {
  case proposalNew = "proposal_new"
  case proposalMatched = "proposal_matched"
  case proposalCancelled = "proposal_cancelled"
  case offerNew = "offer_new"
  case offerAccepted = "offer_accepted"
  case offerRejected = "offer_rejected"
  case executionStarted = "execution_started"
  case executionCompleted = "execution_completed"
  case paymentCompleted = "payment_completed"
  case paymentFailed = "payment_failed"
  case paymentReminder = "payment_reminder"
  case systemAnnouncement = "system_announcement"
  case custom
  case offerSubmitted = "offer_submitted"
  case meetingConfirmed = "meeting_confirmed"
  case disputeRaised = "dispute_raised"
  case unknown = "__unknown__"

  init(from decoder: any Decoder) throws {
    let rawValue = try decoder.singleValueContainer().decode(String.self)
    if let known = NotificationType(rawValue: rawValue), known != .unknown {
      self = known
    } else {
      notificationTypeLogger.error("알 수 없는 notification_type: \(rawValue, privacy: .public)")
      self = .unknown
    }
  }
}
