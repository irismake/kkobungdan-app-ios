//
//  AppBar.swift
//  OderRun
//
//  Created by 김가희 on 3/17/26.
//

import SwiftUI

struct AppBar: View {
  var title: String?
  /// 단계별 진행 표시 (현재 단계, 전체 단계). nil 이면 표시하지 않는다.
  var progress: (current: Int, total: Int)?
  var onBack: (() -> Void)?

  var body: some View {
    ScreenContainer {
      HStack(spacing: 0) {
        if let onBack {
          Button(action: onBack) {
            Image("icon_previous")
              .resizable()
              .frame(width: 24, height: 24)
          }
        }
        if let title, !title.isEmpty {
          Gap.h(8)
          Text(title)
            .textStyle(.heading3)
            .foregroundColor(Color.gray900)
        }

        Spacer()
        
        if let progress {
          Text("\(progress.current)/\(progress.total)")
            .textStyle(.body2)
            .foregroundColor(Color.gray900)
        }
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
