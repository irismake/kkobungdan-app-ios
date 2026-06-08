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

struct MissionParticipant: Equatable {
  let id: String
  let name: String
  let phone: String
}

struct Mission: Equatable, Identifiable {
  let id: Int64
  let offerID: Int64
  let proposalID: Int64
  let orderer: MissionParticipant
  let runner: MissionParticipant
  let status: MissionStatus
}
