//
//  ReportReason.swift
//  OderRun
//
//  신고 사유 선택지. 서버 신고 엔드포인트가 아직 스펙에 없어 클라이언트 고정 목록으로 둔다.
//  TODO: 서버 신고 API 연동 시 서버 스펙(코드 값)과 맞춰 매핑한다.
//

import Foundation

/// 신고 사유 (고정 선택지).
enum ReportReason: String, CaseIterable, Identifiable {
  /// 광고 또는 스팸이에요
  case advertisement
  /// 욕설이나 혐오 표현이 있어요
  case abusiveLanguage
  /// 거짓 정보 같아요
  case falseInformation
  /// 부적절한 사진이나 내용이에요
  case inappropriate
  /// 기타 — 상세 사유 작성 필수
  case etc

  var id: String {
    rawValue
  }

  var displayText: String {
    switch self {
    case .advertisement: "광고 또는 스팸이에요"
    case .abusiveLanguage: "욕설이나 혐오 표현이 있어요"
    case .falseInformation: "거짓 정보 같아요"
    case .inappropriate: "부적절한 사진이나 내용이에요"
    case .etc: "기타"
    }
  }

  /// 선택 시 상세 사유 작성이 필수인지 여부.
  var requiresDetail: Bool {
    self == .etc
  }
}
