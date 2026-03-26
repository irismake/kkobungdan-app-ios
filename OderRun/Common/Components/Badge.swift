//
//  Badge.swift
//  OderRun
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct Badge: View {
  let text: String
  var textColor: Color = .rose500
  var bgColor: Color = .rose000

  var body: some View {
    Text(text)
      .font(.custom("Pretendard-Medium", size: 12))
      .kerning(-0.1)
      .lineSpacing(20)
      .foregroundColor(textColor)
      .padding(.horizontal, 8)
      .padding(.vertical, 2)
      .background(bgColor)
      .clipShape(RoundedRectangle(cornerRadius: 4))
  }
}

#Preview {
  VStack(spacing: 8) {
    Badge(text: "필수")
    Badge(text: "미입금")
    Badge(text: "대기중", textColor: Color.blue500, bgColor: Color.blue000)
  }
}
