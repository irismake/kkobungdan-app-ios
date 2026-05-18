//
//  ProposalStatus.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

enum ProposalStatus: String {
  /// 등록 (미입금)
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
