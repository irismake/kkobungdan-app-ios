//
//  Badge.swift
//  OderRun
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct RequiredBadge: View {
  var body: some View {
    Text("필수")
      .font(.custom("Pretendard-Regular", size: 11))
      .kerning(0)
      .lineSpacing(16)
      .foregroundColor(.primary)
      .padding(.horizontal, 8)
      .padding(.vertical, 2)
      .background(Color.rose000)
      .clipShape(RoundedRectangle(cornerRadius: 4))
  }
}

#Preview {
  RequiredBadge()
}
