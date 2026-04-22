//
//  Offer.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct Offer: Equatable, Identifiable {
  let id: Int64
  let proposalID: Int64
  let runnerID: String
  let status: OfferStatus
  let createdAt: Date
}
