//
//  Bank.swift
//  OderRun
//
//  은행 참조 데이터(표시명). 서버는 은행을 코드 없이 이름 문자열로만 주고받는다.
//

import Foundation

enum Bank {
  /// 선택 가능한 은행 표시명 목록.
  static let displayNames: [String] = [
    "NH 농협", "카카오뱅크", "KB 국민",
    "토스뱅크", "신한", "우리",
    "IBK기업", "하나", "새마을"
  ]
}
