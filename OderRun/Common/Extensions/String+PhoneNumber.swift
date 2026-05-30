//
//  String+PhoneNumber.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import Foundation

extension String {
  /// 숫자만 추려 최대 11자리까지 010-1234-5678 형태로 포맷한다.
  var formattedKoreanPhoneNumber: String {
    let digits = String(filter(\.isNumber).prefix(11))
    switch digits.count {
    case 0 ... 3:
      return digits
    case 4 ... 7:
      let start = digits.prefix(3)
      let rest = digits.dropFirst(3)
      return "\(start)-\(rest)"
    default:
      let start = digits.prefix(3)
      let middle = digits.dropFirst(3).prefix(4)
      let rest = digits.dropFirst(7)
      return "\(start)-\(middle)-\(rest)"
    }
  }
}
