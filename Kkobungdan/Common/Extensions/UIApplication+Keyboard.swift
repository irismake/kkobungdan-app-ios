//
//  UIApplication+Keyboard.swift
//  Kkobungdan
//

import UIKit

extension UIApplication {
  /// 현재 열려 있는 키보드를 내린다 (first responder resign).
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
