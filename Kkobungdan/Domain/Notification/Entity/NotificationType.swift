//
//  NotificationType.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

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
  case systemAnnouncement = "system_announcement"
  case custom
  case offerSubmitted = "offer_submitted"
  case meetingConfirmed = "meeting_confirmed"
  case disputeRaised = "dispute_raised"
}
