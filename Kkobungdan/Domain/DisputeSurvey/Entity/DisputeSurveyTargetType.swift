//
//  DisputeSurveyTargetType.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/19/26.
//

import Foundation

/// 분쟁 설문 대상. (서버: `DisputeSurveyTargetType`)
enum DisputeSurveyTargetType: String, CaseIterable {
  /// 주문자(요청자) 대상 설문
  case order = "ORDER"
  /// 러너 대상 설문
  case runner = "RUNNER"
}
