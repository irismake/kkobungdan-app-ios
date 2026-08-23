//
//  KakaoSignInController.swift
//  Kkobungdan
//
//  Created by 김가희 on 5/12/26.
//

import Foundation
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoSDKUser

enum KakaoSignInError: Error {
  case canceled
  case tokenMissing
  case unknown
}

@MainActor
final class KakaoSignInController {
  nonisolated init() {}

  func requestSignIn() async throws -> String {
    try await withCheckedThrowingContinuation { continuation in
      let loginClosure: (OAuthToken?, Error?) -> Void = { token, error in
        if let error {
          if case let SdkError.ClientFailed(reason, _) = error, reason == .Cancelled {
            continuation.resume(throwing: KakaoSignInError.canceled)
          } else {
            continuation.resume(throwing: KakaoSignInError.unknown)
          }
          return
        }
        guard let accessToken = token?.accessToken else {
          continuation.resume(throwing: KakaoSignInError.tokenMissing)
          return
        }
        continuation.resume(returning: accessToken)
      }

      if UserApi.isKakaoTalkLoginAvailable() {
        UserApi.shared.loginWithKakaoTalk(completion: loginClosure)
      } else {
        UserApi.shared.loginWithKakaoAccount(completion: loginClosure)
      }
    }
  }
}
