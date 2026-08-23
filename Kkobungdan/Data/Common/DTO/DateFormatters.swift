//
//  DateFormatters.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum DateFormatters {
  static let iso8601: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter
  }()

  private static let iso8601Fractional: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()

  /// 서버가 타임존 표기 없이 내려주는 문자열(예: `2026-07-20T06:42:00`)은 UTC 시각이다.
  static let utcDateTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter
  }()

  private static let utcDateTimeFractional: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "UTC")
    return formatter
  }()

  static func parse(_ raw: String) -> Date {
    if let date = iso8601.date(from: raw) {
      return date
    }
    if let date = iso8601Fractional.date(from: raw) {
      return date
    }
    if let date = utcDateTime.date(from: raw) {
      return date
    }
    if let date = utcDateTimeFractional.date(from: raw) {
      return date
    }
    return Date()
  }

  static func format(_ date: Date) -> String {
    iso8601.string(from: date)
  }
}
