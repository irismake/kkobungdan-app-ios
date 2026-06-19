//
//  BottomActionBar.swift
//  OderRun
//
//  Created by 김가희 on 3/18/26.
//

import SwiftUI

struct BottomActionBar: View {
  let title: String
  var isEnabled: Bool = true
  let action: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)

      ScreenContainer {
        FillButton(title: title, isEnabled: isEnabled, action: action)
          .padding(.top, 16)
          .padding(.bottom, 20)
      }
    }
    .background(Color.white)
  }
}

#Preview {
  VStack {
    Spacer()
    BottomActionBar(title: "동의하고 시작하기", isEnabled: true, action: {})
    BottomActionBar(title: "동의하고 시작하기", isEnabled: false, action: {})
  }
}
