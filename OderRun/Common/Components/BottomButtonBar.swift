//
//  BottomButtonBar.swift
//  OderRun
//
//  Created by 김가희 on 3/18/26.
//

import SwiftUI

struct BottomButtonBar: View {
  let title: String
  var isEnabled: Bool = true
  let action: () -> Void

  var body: some View {
    VStack(spacing: 0) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)

      ScreenContainer {
        CompleteButton(title: title, isEnabled: isEnabled, action: action)
          .padding(.top, 16)
          .padding(.bottom, 32)
      }
    }
  }
}

#Preview {
  VStack {
    Spacer()
    BottomButtonBar(title: "동의하고 시작하기", isEnabled: true, action: {})
    BottomButtonBar(title: "동의하고 시작하기", isEnabled: false, action: {})
  }
}
