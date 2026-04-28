//
//  ProposalStatus.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

enum ProposalStatus: String {
  /// 등록
  case posted = "POSTED"
  /// 지원 옴
  case offered = "OFFERED"
  /// 지원자 선택
  case matched = "MATCHED"
  /// 오더 취소
  case cancelled = "CANCELLED"
}
