//
//  UserAlarmRequest.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//
//  `PATCH /v1/user/alarm` (알림 수신 설정) 요청 바디. (서버: `UserAlarmRequest`)
//

import Foundation

struct UserAlarmRequest: Encodable {
  let alarmEnabled: Bool
}
