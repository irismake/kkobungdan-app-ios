//
//  ActivityStage.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  '내 활동' 탭에서 사용하는 세그먼트 / 필터 단계 enum.
//

import Foundation

enum ActivitySegment: String, CaseIterable {
  case orderer
  case runner

  var title: String {
    switch self {
    case .orderer: return "요청"
    case .runner: return "수행 기록"
    }
  }
}

enum ActivityFilter: String {
  case all = "전체"
  case unpaid = "미입금"
  case waiting = "대기중"
  case inProgress = "진행중"
  case completed = "완료"
  case cancelled = "취소"

  /// orderer(요청) 세그먼트 카테고리.
  static let ordererCases: [ActivityFilter] = [.all, .unpaid, .waiting, .inProgress, .completed, .cancelled]
  /// runner(웨이팅 기록) 세그먼트 카테고리. 러너 offer 에는 '미입금' 상태가 없다.
  static let runnerCases: [ActivityFilter] = [.all, .waiting, .inProgress, .completed, .cancelled]

  /// `/v1/proposal/own` 조회 시 보낼 status 필터. `all` 은 빈 배열(전체).
  var proposalStatuses: [ProposalStatus] {
    switch self {
    case .all: return []
    case .unpaid: return [.holding]
    case .waiting: return [.posted, .offered]
    case .inProgress: return [.matched, .orderCompleted, .disputed]
    case .completed: return [.allCompleted]
    case .cancelled: return [.cancelled, .resolved]
    }
  }

  /// `/v1/offer/own` 조회 시 보낼 status 필터. `all` 은 빈 배열(전체).
  var offerStatuses: [OfferStatus] {
    switch self {
    case .all, .unpaid: return []
    case .waiting: return [.waiting]
    case .inProgress: return [.accepted, .runnerCompleted, .disputed]
    case .completed: return [.allCompleted]
    case .cancelled: return [.rejected, .cancelled, .resolved]
    }
  }
}
