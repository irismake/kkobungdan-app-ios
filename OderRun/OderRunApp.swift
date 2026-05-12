//
//  OderRunApp.swift
//  OderRun
//
//  Created by 김가희 on 3/4/26.
//

import KakaoSDKAuth
import KakaoSDKCommon
import SwiftUI

@main
struct OderRunApp: App {
  init() {
    // 로컬 전용: 카카오 개발자 콘솔의 네이티브 앱 키로 교체 (저장소에는 커밋하지 않음)
    KakaoSDK.initSDK(appKey: "00000000000000000000000000000000")
  }

  var body: some Scene {
    WindowGroup {
      ContentView()
        .onOpenURL { url in
          if AuthApi.isKakaoTalkLoginUrl(url) {
            AuthController.handleOpenUrl(url: url)
          }
        }
    }
  }
}
