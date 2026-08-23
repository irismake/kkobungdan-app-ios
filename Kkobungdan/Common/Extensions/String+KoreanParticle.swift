//
//  String+KoreanParticle.swift
//  Kkobungdan
//

import Foundation

extension String {
  /// 마지막 글자에 받침(종성)이 있는지 여부.
  /// 한글 음절이 아니면 `false`. 을/를·은/는·이/가 등 조사 선택에 사용한다.
  var hasBatchim: Bool {
    guard let last = unicodeScalars.last else {
      return false
    }
    let value = last.value
    // 한글 음절 영역(가 ~ 힣)
    guard (0xac00 ... 0xd7a3).contains(value) else {
      return false
    }
    // (음절 - 0xAC00) % 28 != 0 이면 종성(받침)이 있다.
    return (value - 0xac00) % 28 != 0
  }
}
