//
//  MissionStatus.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum MissionStatus: String {
  case created = "CREATED"
  case inProgress = "IN_PROGRESS"
  case deliveryCompleted = "DELIVERY_COMPLETED"
  case receivedConfirmed = "RECEIVED_CONFIRMED"
  case settled = "SETTLED"
  case disputed = "DISPUTED"
  case refunded = "REFUNDED"
}
