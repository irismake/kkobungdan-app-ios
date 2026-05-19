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
  /// 선택 받음
  case accepted = "ACCEPTED"
  /// 진행 완료
  case complete = "COMPLETE"
  /// 다른 지원자가 선택됨 / 요청 자체가 취소됨
  case rejected = "REJECTED"
  /// 요청 취소함
  case cancelled = "CANCELLED"
}
