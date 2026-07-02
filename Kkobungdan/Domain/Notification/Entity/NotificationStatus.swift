//
//  NotificationStatus.swift
//  Kkobungdan
//
//  Created by 김가희 on 6/11/26.
//

import Foundation

enum NotificationStatus: String, Decodable {
  case pending
  case sent
  case delivered
  case failed
  case read
}
