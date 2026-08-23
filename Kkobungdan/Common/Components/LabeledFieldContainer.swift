//
//  LabeledFieldContainer.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 라벨 + 입력 컨트롤을 묶는 공통 레이아웃.
struct LabeledFieldContainer<Content: View>: View {
  let label: String
  @ViewBuilder let content: () -> Content

  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(label)
        .textStyle(.body2)
        .foregroundColor(.gray800)

      content()
    }
  }
}
