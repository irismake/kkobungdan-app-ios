//
//  SignupField.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

extension View {
  /// 회원가입 입력 필드의 공통 박스 스타일(둥근 테두리 + 활성 시 indigo 강조).
  func signupFieldBox(isActive: Bool) -> some View {
    padding(.horizontal, 16)
      .padding(.vertical, 12)
      .background(Color.white)
      .clipShape(RoundedRectangle(cornerRadius: 8))
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .stroke(isActive ? Color.indigo500 : Color.gray200, lineWidth: 1)
      )
  }
}

/// 라벨 + 입력 컨트롤을 묶는 공통 레이아웃.
struct SignupFieldContainer<Content: View>: View {
  let label: String
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .textStyle(.body2)
        .foregroundColor(.gray800)

      content()
    }
    .padding(.horizontal, 16)
  }
}
