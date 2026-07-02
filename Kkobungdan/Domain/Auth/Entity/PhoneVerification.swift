//
//  PhoneVerification.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/8/26.
//

import Foundation

/// SMS 인증번호 발송 결과. 인증번호 입력 화면의 만료 타이머를 구동한다.
struct PhoneVerification: Equatable {
  let expiresAt: Date
}
