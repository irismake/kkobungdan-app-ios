//
//  OfferStatus.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum OfferStatus: String {
  /// 선택 기다리는중
  case waiting = "WAITING"
  /// 선택 받음 (매칭)
  case accepted = "ACCEPTED"
  /// 러너 완료 (배달 완료 처리)
  case runnerCompleted = "RUNNER_COMPLETED"
  /// 양측 완료 (정산)
  case allCompleted = "ALL_COMPLETED"
  /// 분쟁 제기됨
  case disputed = "DISPUTED"
  /// 분쟁 해결
  case resolved = "RESOLVED"
  /// 다른 지원자가 선택됨 / 요청 자체가 취소됨
  case rejected = "REJECTED"
  /// 요청 취소함
  case cancelled = "CANCELLED"
}
