//
//  MissionDisplay.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//

import Foundation

enum MissionDisplay {
  static func statusBadge(_ status: MissionStatus) -> BadgeItem {
    switch status {
    case .created:
      return BadgeItem(text: "수락 완료", textColor: .blue500, bgColor: .blue000)
    case .inProgress:
      return BadgeItem(text: "진행 중", textColor: .indigo500, bgColor: .blue000)
    case .deliveryCompleted:
      return BadgeItem(text: "전달 완료", textColor: .amber600, bgColor: .amber000)
    case .receivedConfirmed:
      return BadgeItem(text: "수령 완료", textColor: .emerald500, bgColor: .emerald000)
    case .settled:
      return BadgeItem(text: "정산 완료", textColor: .emerald500, bgColor: .emerald000)
    case .disputed:
      return BadgeItem(text: "분쟁 중", textColor: .rose500, bgColor: .rose000)
    case .refunded:
      return BadgeItem(text: "환불 완료", textColor: .gray500, bgColor: .gray100)
    }
  }
}
