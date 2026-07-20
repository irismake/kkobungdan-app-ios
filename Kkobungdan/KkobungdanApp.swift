//
//  KkobungdanApp.swift
//  Kkobungdan
//
//  Created by 김가희 on 3/4/26.
//

import KakaoSDKAuth
import KakaoSDKCommon
import SwiftUI

@main
struct KkobungdanApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @State private var session = SessionViewModel()

  init() {
    guard let appKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_NATIVE_APP_KEY") as? String,
          !appKey.isEmpty
    else {
      fatalError("KAKAO_NATIVE_APP_KEY 가 Info.plist 에 없습니다. Secrets.xcconfig 설정을 확인하세요.")
    }
    KakaoSDK.initSDK(appKey: appKey)
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(session)
        .onOpenURL { url in
          if AuthApi.isKakaoTalkLoginUrl(url) {
            AuthController.handleOpenUrl(url: url)
          }
        }
    }
  }
}
