//
//  AppVersion.swift
//  Kkobungdan
//

import Foundation

/// "1.2.3" 형태의 버전 문자열을 숫자 단위로 비교하기 위한 값 타입.
///
/// - 마침표로 구분된 각 컴포넌트를 정수로 파싱하며, 숫자가 아니거나 비면 0으로 취급한다.
/// - 길이가 다르면 짧은 쪽의 부족한 자리를 0으로 채워 비교한다. (예: "1.2" == "1.2.0")
struct AppVersion: Comparable {
  let components: [Int]

  init(_ string: String) {
    components = string
      .split(separator: ".", omittingEmptySubsequences: false)
      .map { Int($0.trimmingCharacters(in: .whitespaces)) ?? 0 }
  }

  static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
    let count = max(lhs.components.count, rhs.components.count)
    for index in 0 ..< count {
      let left = index < lhs.components.count ? lhs.components[index] : 0
      let right = index < rhs.components.count ? rhs.components[index] : 0
      if left != right {
        return left < right
      }
    }
    return false
  }

  static func == (lhs: AppVersion, rhs: AppVersion) -> Bool {
    let count = max(lhs.components.count, rhs.components.count)
    for index in 0 ..< count {
      let left = index < lhs.components.count ? lhs.components[index] : 0
      let right = index < rhs.components.count ? rhs.components[index] : 0
      if left != right {
        return false
      }
    }
    return true
  }
}
