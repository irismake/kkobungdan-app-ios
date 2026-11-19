//
//  ProposalStatus.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

enum ProposalStatus: String, CaseIterable {
  /// 등록 대기 (입금 확인 전)
  case holding = "HOLDING"
  /// 등록 완료 (입금 완료, 지원 대기중)
  case posted = "POSTED"
  /// 지원 옴
  case offered = "OFFERED"
  /// 지원자 선택 (매칭)
  case matched = "MATCHED"
  /// 오더러 수령 확인 완료 (러너 완료 대기)
  case orderCompleted = "ORDER_COMPLETED"
  /// 양측 완료 (정산)
  case allCompleted = "ALL_COMPLETED"
  /// 분쟁 제기됨
  case disputed = "DISPUTED"
  /// 환불 처리중 (분쟁이 환불로 종결됐거나, 입금 확인 후 취소되어 환불 생성됨)
  case refundPending = "REFUND_PENDING"
  /// 환불 완료
  case refunded = "REFUNDED"
  /// 신고 처리 (게시글 신고가 승인돼 내려감)
  case reported = "REPORTED"
  /// 오더 취소 (입금 전 취소 등 환불이 필요 없는 종료)
  case cancelled = "CANCELLED"
}
