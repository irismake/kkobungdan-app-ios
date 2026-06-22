//
//  UserFcmTokenRequest.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `PATCH /v1/user/fcm-token` (FCM 토큰 갱신) 요청 바디. (서버: `UserFcmTokenRequest`)
//

import Foundation

struct UserFcmTokenRequest: Encodable {
  let fcmToken: String
}
