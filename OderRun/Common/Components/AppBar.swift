//
//  AppBar.swift
//  OderRun
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct AppBar: View {
  var title: String?
  var isProgress: Bool = false
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
        if let title, !title.isEmpty {
          Gap.h(8)
          Text(title)
            .font(.custom("Pretendard-SemiBold", size: 18))
            .kerning(-0.4)
            .appLineHeight(28, fontName: "Pretendard-SemiBold", fontSize: 18)
            .foregroundColor(Color.gray900)
        }

        Spacer()
          .frame(height: 40)
        if isProgress {
          Text("1/3")
            .font(.custom("Pretendard-Medium", size: 14))
            .kerning(-0.1)
            .appLineHeight(20, fontName: "Pretendard-Medium", fontSize: 14)
            .foregroundColor(Color.gray900)
        }
      }
    }
  }
}

#Preview {
  ScreenContainer {
    AppBar(title: "약관 동의", onBack: {})
  }
}
