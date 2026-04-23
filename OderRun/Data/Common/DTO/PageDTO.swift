//
//  PageDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct PageDTO<T: Decodable>: Decodable {
  let content: [T]
  let totalElements: Int
  let totalPages: Int
  let number: Int
  let size: Int
  let first: Bool?
  let last: Bool?
  let empty: Bool?
}
