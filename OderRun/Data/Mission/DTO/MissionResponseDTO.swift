//
//  MissionResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct MissionResponseDTO: Decodable {
  let id: Int64
  let offerID: Int64
  let proposalID: Int64
  let ordererID: String
  let runnerID: String
  let status: String
  let runFee: Int
  let itemPrice: Int
  let proofImageURL: String?
  let createdAt: String
}

extension MissionResponseDTO {
  func toDomain() -> Mission {
    Mission(
      id: id,
      offerID: offerID,
      proposalID: proposalID,
      ordererID: ordererID,
      runnerID: runnerID,
      status: MissionStatus(rawValue: status) ?? .created,
      runFee: runFee,
      itemPrice: itemPrice,
      proofImageURL: proofImageURL,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
