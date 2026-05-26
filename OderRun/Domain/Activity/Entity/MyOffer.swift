//
//  MyOffer.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  /v1/offer/own 응답 항목. 현재 로그인한 러너(runner)가 제출한 offer 한 건.
//

import Foundation

struct MyOffer: Equatable, Identifiable {
  let id: Int64
  let proposalID: Int64
  let runnerID: String
  let status: OfferStatus
  let createdAt: Date
}
