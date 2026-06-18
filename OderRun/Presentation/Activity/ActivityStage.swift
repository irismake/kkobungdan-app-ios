//
//  ActivityStage.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//
//  '내 활동' 탭에서 사용하는 필터 단계 enum.
//

import Foundation

enum ActivityStage {
  case unpaid
  case waiting
  case inProgress
  case completed
  case cancelled
}

extension MyProposal {
  var stage: ActivityStage {
    switch status {
    case .holding: return .unpaid
    case .posted, .offered: return .waiting
    case .matched, .orderCompleted, .disputed: return .inProgress
    case .allCompleted: return .completed
    case .cancelled, .resolved: return .cancelled
    }
  }
}

extension MyOffer {
  var stage: ActivityStage {
    switch status {
    case .waiting: return .waiting
    case .accepted, .runnerCompleted, .disputed: return .inProgress
    case .allCompleted: return .completed
    case .rejected, .cancelled, .resolved: return .cancelled
    }
  }
}
