//
//  DateFormatters.swift
//  OderRun
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

  static let localDateTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    return formatter
  }()

  static func parse(_ raw: String) -> Date {
    if let date = iso8601.date(from: raw) {
      return date
    }
    if let date = localDateTime.date(from: raw) {
      return date
    }
    return Date()
  }

  static func format(_ date: Date) -> String {
    iso8601.string(from: date)
  }
}
