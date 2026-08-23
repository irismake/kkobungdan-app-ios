//
//  PageDTO.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

/// 서버 `PageResponse[...]` 스키마. 모든 필드가 required 다.
struct PageDTO<T: Decodable>: Decodable {
  let content: [T]
  let totalElements: Int
  let totalPages: Int
  let pageNumber: Int
  let pageSize: Int
  let first: Bool
  let last: Bool
}
