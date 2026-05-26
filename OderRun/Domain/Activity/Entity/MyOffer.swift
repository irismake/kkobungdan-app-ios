//
//  MyOffer.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  /v1/offer/own 응답 항목. 현재 로그인한 러너(runner)가 제출한 offer 한 건과
//  그 offer 가 가리키는 proposal 정보(title/content/deadline 등)를 함께 담는다.
//

import Foundation

struct MyOffer: Equatable, Identifiable {
  /// offer 의 id.
  let id: Int64
  /// 이 offer 가 가리키는 proposal 의 id. 활동 탭에서 상세 진입에 사용한다.
  let proposalID: Int64
  let runnerName: String
  let status: OfferStatus
  let createdAt: Date
  // TODO: 서버에서 title/content/deadline/errandFee/meetingAt/itemPrice/deposit 필드 추가되면 "" · 0 · nil 제거
  let title: String
  let content: String
  let deadline: Date
  let meetingAt: Date?
  let errandFee: Int
  let itemPrice: Int?
  let deposit: Int?
}
