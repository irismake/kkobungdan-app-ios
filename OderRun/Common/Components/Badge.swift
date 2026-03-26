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
      .odrStyle(.caption2())
      .padding(.horizontal, 8)
      .padding(.vertical, 2)
      .background(Color.rose000)
      .clipShape(RoundedRectangle(cornerRadius: 4))
  }
}

#Preview {
  RequiredBadge()
}
