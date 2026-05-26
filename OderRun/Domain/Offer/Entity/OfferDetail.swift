//
//  OfferDetail.swift
//  OderRun
//
//  Created by 김가희 on 5/19/26.
//
//  `GET /v1/offer/{offerId}` 응답에 대응되는 도메인 모델.
//  offer 기본 필드 + 지원한 러너의 표시용 프로필(nickname/level/grade)을 함께 담는다.
//

import Foundation

struct OfferDetail: Equatable, Identifiable {
  let id: Int64
  let proposalID: Int64
  let runnerID: String
  let status: OfferStatus
  let createdAt: Date
}
