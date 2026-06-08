//
//  MissionAction.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

/// 미션 상태 전이 행위. 행위별로 분리된 POST 엔드포인트(`complete-delivery` /
/// `confirm-received` / `dispute`)에 매핑된다.
enum MissionAction: String {
  case completeDelivery = "COMPLETE_DELIVERY"
  case confirmReceived = "CONFIRM_RECEIVED"
  case dispute = "DISPUTE"
}
