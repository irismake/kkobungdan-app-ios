import Foundation

/// 고객센터 문의 연락처. 앱 전역에서 이 상수를 사용한다.
enum SupportContact {
  static let email = "orderrun365@gmail.com"

  /// 고객센터로 바로 메일을 보낼 수 있는 mailto URL.
  static var mailtoURL: URL? {
    URL(string: "mailto:\(email)")
  }
}
