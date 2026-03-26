//
//  AppBar.swift
//  OderRun
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct AppBar: View {
  let title: String
  var onBack: (() -> Void)?

  var body: some View {
    ScreenContainer {
      HStack(spacing: 0) {
        if let onBack {
          Button(action: onBack) {
            Image("arrow_left")
              .resizable()
              .frame(width: 24, height: 24)
          }
        }
        Gap.h(8)

        Text(title)
          .odrStyle(.title4(weight: .semibold, color: Color.gray900))

        Spacer()
      }
      .frame(height: 40)
    }
  }
}

#Preview {
  ScreenContainer {
    AppBar(title: "약관 동의", onBack: {})
  }
}
