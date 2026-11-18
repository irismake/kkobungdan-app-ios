//
//  DisplayFormatter.swift
//  Kkobungdan
//
//  화면에 표시할 날짜·시간·금액 포맷팅 유틸.
//  상태 → 배지 매핑은 `ActivityStatusBadge` 참고.
//

import Foundation

enum DisplayFormatter {
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

  private static let chatTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "a hh:mm"
    return formatter
  }()

  private static let chatDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "M월 d일"
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

  /// 채팅 목록 시각. 오늘이면 "오후 04:42", 이전이면 "11월 10일".
  static func chatTimeString(_ date: Date, now: Date = Date()) -> String {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    return calendar.isDate(date, inSameDayAs: now)
      ? chatTimeFormatter.string(from: date)
      : chatDateFormatter.string(from: date)
  }

  /// 채팅 메시지 시각. 항상 "오후 04:42".
  static func messageTimeString(_ date: Date) -> String {
    chatTimeFormatter.string(from: date)
  }

  /// 채팅 날짜 구분선용 — 두 시각이 같은 날(한국 시간)인지.
  static func isSameChatDay(_ lhs: Date, _ rhs: Date) -> Bool {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Seoul") ?? .current
    return calendar.isDate(lhs, inSameDayAs: rhs)
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
