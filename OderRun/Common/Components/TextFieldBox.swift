//
//  TextFieldBox.swift
//  OderRun
//
//  Created by 김가희 on 6/18/26.
//

import SwiftUI

extension View {
  /// 텍스트 입력 필드의 공통 박스 스타일(둥근 테두리 + 활성 시 indigo 강조).
  /// `FocusTextField`·`ContentTextField` 등 모든 입력 필드가 이 디자인을 공유한다.
  func textFieldBox(isActive: Bool, background: Color = .clear) -> some View {
    padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(background)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(isActive ? Color.indigo500 : Color.gray200, lineWidth: 1)
      )
  }
}
