//
//  ApiResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct ApiResponseDTO<T: Decodable>: Decodable {
  let success: Bool
  let data: T?
  let message: String?
}

struct ApiErrorDTO: Decodable {
  let success: Bool
  let error: ApiErrorDetailDTO
  let timestamp: String
}

struct ApiErrorDetailDTO: Decodable {
  let code: String
  let message: String
}
