//
//  ProposalStatus.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

enum ProposalStatus: String {
  /// 등록 대기 (입금 확인 전)
  case holding = "HOLDING"
  /// 등록 완료 (입금 완료)
  case posted = "POSTED"
  /// 입금 완료, 지원 대기중
  case waiting = "WAITING"
  /// 지원 옴
  case offered = "OFFERED"
  /// 지원자 선택
  case matched = "MATCHED"
  /// 진행 완료
  case complete = "COMPLETE"
  /// 오더 취소
  case cancelled = "CANCELLED"
}
