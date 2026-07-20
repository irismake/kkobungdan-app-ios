//
//  AppDelegate.swift
//  Kkobungdan
//

import FirebaseCore
import FirebaseMessaging
import OSLog
import UIKit

private let pushLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Push")

final class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // GoogleService-Info.plist 는 Firebase 콘솔에서 받아 Kkobungdan/ 에 넣는다.
    guard Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil else {
      pushLogger.fault("GoogleService-Info.plist 가 번들에 없습니다. FCM 초기화를 건너뜁니다.")
      return true
    }

    FirebaseApp.configure()
    Messaging.messaging().delegate = self
    UNUserNotificationCenter.current().delegate = self

    Task {
      do {
        let granted = try await UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .badge, .sound])
        pushLogger.info("알림 권한 요청 결과: \(granted)")
      } catch {
        pushLogger.error("알림 권한 요청 실패: \(error)")
      }
    }
    application.registerForRemoteNotifications()
    return true
  }

  func application(
    _: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
  }

  func application(
    _: UIApplication,
    didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    pushLogger.error("APNs 등록 실패: \(error)")
  }
}

// MARK: - MessagingDelegate

extension AppDelegate: MessagingDelegate {
  nonisolated func messaging(_: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    pushLogger.info("FCM 토큰 갱신: \(fcmToken ?? "nil", privacy: .private)")
    guard let fcmToken else {
      return
    }
    FcmTokenStorage.shared.token = fcmToken

    guard TokenStorage.shared.refreshToken != nil else {
      return
    }
    Task {
      do {
        try await UpdateFcmTokenUseCase(userRepository: DIContainer.userRepository)
          .execute(token: fcmToken)
      } catch {
        pushLogger.error("FCM 토큰 서버 갱신 실패: \(error)")
      }
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
  nonisolated func userNotificationCenter(
    _: UNUserNotificationCenter,
    willPresent _: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    // 탭바 안읽음 뱃지 갱신 트리거
    Task { @MainActor in
      PushRouteStore.shared.foregroundPushCount += 1
    }
    // 포그라운드에서도 배너 표시
    completionHandler([.banner, .list, .badge, .sound])
  }

  nonisolated func userNotificationCenter(
    _: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let userInfo = response.notification.request.content.userInfo
    if let payload = PushPayload(userInfo: userInfo) {
      pushLogger.info(
        "푸시 탭: \(payload.type.rawValue) proposal=\(payload.proposalID) offer=\(payload.offerID)"
      )
      Task { @MainActor in
        PushRouteStore.shared.pending = payload
      }
    } else {
      pushLogger.warning("푸시 탭: payload 파싱 실패 — \(String(describing: userInfo))")
    }
    completionHandler()
  }
}
