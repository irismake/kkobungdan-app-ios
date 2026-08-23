//
//  PolicyURL.swift
//  Kkobungdan
//
//  이용약관·개인정보 처리방침·운영정책 문서 URL. 앱 전역에서 이 상수를 사용한다.
//

import Foundation

enum PolicyURL {
  /// 이용약관
  static let termsOfService = URL(string: "https://grave-hoodie-0b9.notion.site/3abd1dee2267805cac46e635c2c3b6bb")!
  /// 개인정보 처리방침
  static let privacyPolicy = URL(string: "https://grave-hoodie-0b9.notion.site/3abd1dee22678027a498c3f2cf458d64")!
  /// 운영정책
  static let operationPolicy = URL(string: "https://grave-hoodie-0b9.notion.site/3abd1dee226780409875c0c67540724d")!
}
