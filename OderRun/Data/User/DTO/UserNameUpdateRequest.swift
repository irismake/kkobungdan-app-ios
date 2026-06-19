//
//  UserNameUpdateRequest.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `PATCH /v1/user/name` (닉네임 변경) 요청 바디. (서버: `UserNameUpdateRequest`)
//

import Foundation

struct UserNameUpdateRequest: Encodable {
  let name: String
}
