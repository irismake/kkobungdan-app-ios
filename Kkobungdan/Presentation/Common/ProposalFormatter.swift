//
//  ProposalFormatter.swift
//  Kkobungdan
//
//  proposal / offer 데이터를 화면에 표시할 때 쓰는 날짜·시간·금액 포맷팅 유틸.
//  상태 → 배지 매핑은 `ActivityStatusBadge` 참고.
//

import Foundation

enum ProposalFormatter {
  private static let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy년 M월 d일"
    return formatter
  }()

  private static let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "a h시"
    return formatter
  }()

  private static let feeFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter
  }()

  static func dateString(_ date: Date) -> String {
    dateFormatter.string(from: date)
  }

  static func timeString(_ date: Date) -> String {
    timeFormatter.string(from: date)
  }

  static func feeString(_ fee: Int) -> String {
    let amount = feeFormatter.string(from: NSNumber(value: fee)) ?? "\(fee)"
    return "\(amount)원"
  }

  static func relativeTimeString(_ date: Date, now: Date = Date()) -> String {
    let diff = now.timeIntervalSince(date)
    switch diff {
    case ..<60:
      return "방금 전"
    case ..<3600:
      return "\(Int(diff / 60))분 전"
    case ..<86400:
      return "\(Int(diff / 3600))시간 전"
    case ..<(86400 * 7):
      return "\(Int(diff / 86400))일 전"
    default:
      let formatter = DateFormatter()
      formatter.locale = Locale(identifier: "ko_KR")
      formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
      formatter.dateFormat = "yyyy. MM. dd a h:mm"
      return formatter.string(from: date)
    }
  }

  static func appliedAtString(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy. M. d. a h:mm:ss '지원'"
    return formatter.string(from: date)
  }
}
