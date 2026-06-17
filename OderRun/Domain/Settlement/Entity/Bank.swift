//
//  Bank.swift
//  OderRun
//
//  은행 참조 데이터(표시명·서버 bankCode). 서버에 은행 목록 API가 없어 클라이언트 상수로 보관한다.
//

import Foundation

enum Bank {
  /// 선택 가능한 은행 표시명 목록.
  static let displayNames: [String] = [
    "NH 농협", "카카오뱅크", "KB 국민",
    "토스뱅크", "신한", "우리",
    "IBK기업", "하나", "새마을"
  ]

  /// 은행 표시명 → 서버 `bankCode` 매핑. (서버 스펙: 2~10자리 숫자)
  /// TODO: 국민 외 나머지 은행 코드 매핑 추가
  static let codes: [String: String] = [
    "KB 국민": "004"
  ]

  /// 표시명에 해당하는 서버 `bankCode`. 미매핑 시 `nil`.
  static func code(for displayName: String) -> String? {
    codes[displayName]
  }
}
