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
  /// 등록 완료 (입금 완료, 지원 대기중)
  case posted = "POSTED"
  /// 지원 옴
  case offered = "OFFERED"
  /// 지원자 선택
  case matched = "MATCHED"
  /// 진행 완료
  // TODO: 서버 status enum 에 아직 누락됨(현재 HOLDING/POSTED/OFFERED/MATCHED/CANCELLED 만 허용).
  //       서버 반영 전까지 COMPLETED 필터 조회는 400 이 날 수 있음.
  case complete = "COMPLETED"
  /// 오더 취소
  case cancelled = "CANCELLED"
}
