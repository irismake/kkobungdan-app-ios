//
//  NotificationMarkReadResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/19/26.
//
//  `POST /v1/notifications/mark-read` 응답의 `data` 페이로드. (서버: `NotificationMarkReadResponse`)
//  전역 디코더가 .convertFromSnakeCase 라 marked_count → markedCount 로 매핑된다.
//

import Foundation

struct NotificationMarkReadResponseDTO: Decodable {
  let markedCount: Int
}

extension NotificationMarkReadResponseDTO {
  func toDomain() -> Int {
    markedCount
  }
}
