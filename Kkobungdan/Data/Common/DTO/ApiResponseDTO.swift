//
//  ApiResponseDTO.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct ApiResponseDTO<T: Decodable>: Decodable {
  let success: Bool
  let data: T?
  let message: String?
}

/// 서버 공통 에러 응답 (`ErrorResponse` 스키마). non-2xx 바디를 이 형태로 디코딩한다.
struct ApiErrorDTO: Decodable {
  let success: Bool?
  let error: ApiErrorDetailDTO
  let timestamp: String?
}

/// `ErrorDetail` 스키마.
struct ApiErrorDetailDTO: Decodable {
  let code: String
  let message: String
  let details: String?
}
