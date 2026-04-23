//
//  Mission.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum MissionRole: String {
  case orderer = "ORDERER"
  case runner = "RUNNER"
}

struct Mission: Equatable, Identifiable {
  let id: Int64
  let offerID: Int64
  let proposalID: Int64
  let ordererID: String
  let runnerID: String
  let status: MissionStatus
  let runFee: Int
  let itemPrice: Int
  let proofImageURL: String?
  let createdAt: Date
}
