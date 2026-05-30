//
//  RootView.swift
//  OderRun
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 앱 시작 시 항상 스플래시를 먼저 노출하고, 준비가 끝나면 ContentView 로 전환한다.
struct RootView: View {
  @State private var showSplash = true

  var body: some View {
    ZStack {
      if showSplash {
        SplashView()
          .transition(.opacity)
      } else {
        ContentView()
      }
    }
    .task {
      // TODO: 추후 토큰 갱신·초기 데이터 로딩 등 부트스트랩 완료를 기다려 전환하도록 교체
      try? await Task.sleep(for: .seconds(1.5))
      withAnimation(.easeInOut(duration: 0.3)) {
        showSplash = false
      }
    }
  }
}

#Preview {
  RootView()
}
