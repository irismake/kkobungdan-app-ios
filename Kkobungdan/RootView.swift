//
//  RootView.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/30/26.
//

import SwiftUI

/// 앱 시작 시 항상 스플래시를 먼저 노출하고, 준비가 끝나면 ContentView 로 전환한다.
/// 부트스트랩 중 Remote Config 로 강제/선택 업데이트 여부를 판정해 필요 시 모달을 띄운다.
struct RootView: View {
  @State private var showSplash = true
  @State private var updateViewModel = AppUpdateViewModel()
  @Environment(\.openURL) private var openURL

  var body: some View {
    ZStack {
      if showSplash {
        SplashView()
          .transition(.opacity)
      } else {
        ContentView()
      }

      updateOverlay
    }
    .task {
      // 스플래시가 보이는 동안 업데이트 정책을 조회한다.
      await updateViewModel.check()
      // TODO: 추후 토큰 갱신·초기 데이터 로딩 등 부트스트랩 완료를 기다려 전환하도록 교체
      try? await Task.sleep(for: .seconds(1.5))
      withAnimation(.easeInOut(duration: 0.3)) {
        showSplash = false
      }
    }
  }

  @ViewBuilder
  private var updateOverlay: some View {
    // 스플래시가 끝난 뒤에만 모달을 노출한다.
    if !showSplash {
      switch updateViewModel.status {
      case let .forced(storeURL, message):
        AppUpdateModal(
          isForced: true,
          message: message,
          onUpdate: { openURL(storeURL) }
        )
        .transition(.opacity)

      case let .optional(storeURL, message):
        if !updateViewModel.isOptionalDismissed {
          AppUpdateModal(
            isForced: false,
            message: message,
            onUpdate: { openURL(storeURL) },
            onLater: { updateViewModel.isOptionalDismissed = true }
          )
          .transition(.opacity)
        }

      case .upToDate:
        EmptyView()
      }
    }
  }
}

#Preview {
  RootView()
    .environment(SessionViewModel())
}
