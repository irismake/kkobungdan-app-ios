//
//  AuthLoginConfirmRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/auth/login/confirm` (로그인 인증번호 확인) 요청 바디. fcmToken 은 서버 optional. (서버: `AuthLoginConfirmRequest`)
//

import Foundation

struct AuthLoginConfirmRequest: Encodable {
  let code: String
  // TODO: fcmToken — 푸시 연동 전까지 stub 값 전송
  let fcmToken: String?
  let phone: String

  init(code: String, phone: String) {
    self.code = code
    self.phone = phone
    fcmToken = AuthLoginConfirmRequest.stubFCMToken
  }
}

extension AuthLoginConfirmRequest {
  // TODO: fcmToken 푸시 연동 시 호출부에서 실제 값 전달로 교체
  static let stubFCMToken: String? = nil
}
