//
//  ReportReason.swift
//  OderRun
//
//  `GET /v1/proposal-report-reasons` 응답에 대응되는 도메인 모델.
//  의뢰 신고 시 사용자에게 보여줄 신고 사유 선택지 한 건.
//

import Foundation

struct ReportReason: Equatable, Identifiable {
  let id: Int64
  let questionText: String
  let displayOrder: Int
}
