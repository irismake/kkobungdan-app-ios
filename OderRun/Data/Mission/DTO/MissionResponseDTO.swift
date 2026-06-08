//
//  MissionResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct MissionParticipantDTO: Decodable {
  let id: String
  let name: String
  let phone: String
}

struct MissionResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let offerID: Int64
  let orderer: MissionParticipantDTO
  let runner: MissionParticipantDTO
  let deliveryProofImageUrl: String?
  let status: String
  let pickupAt: String?
  let deliveryCompletedAt: String?
  let receivedConfirmedAt: String?
  let settledAt: String?
  let disputeReason: String?
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case offerID = "offerId"
    case orderer
    case runner
    case deliveryProofImageUrl
    case status
    case pickupAt
    case deliveryCompletedAt
    case receivedConfirmedAt
    case settledAt
    case disputeReason
    case createdAt
  }
}

extension MissionResponseDTO {
  func toDomain() -> Mission {
    // TODO: itemPrice, totalAmount, deliveryProofImageUrl, pickupAt, deliveryCompletedAt,
    //       receivedConfirmedAt, settledAt, disputeReason, createdAt — UI 반영 시 엔티티에 추가
    Mission(
      id: id,
      offerID: offerID,
      proposalID: proposalID,
      orderer: MissionParticipant(id: orderer.id, name: orderer.name, phone: orderer.phone),
      runner: MissionParticipant(id: runner.id, name: runner.name, phone: runner.phone),
      status: MissionStatus(rawValue: status) ?? .created
    )
  }

  // TODO: deliveryProofImageUrl UI 반영 시 Mission 엔티티에 추가
  static let stubDeliveryProofImageUrl: String? = nil
  // TODO: pickupAt UI 반영 시 Mission 엔티티에 추가
  static let stubPickupAt: String? = nil
  // TODO: deliveryCompletedAt UI 반영 시 Mission 엔티티에 추가
  static let stubDeliveryCompletedAt: String? = nil
  // TODO: receivedConfirmedAt UI 반영 시 Mission 엔티티에 추가
  static let stubReceivedConfirmedAt: String? = nil
  // TODO: settledAt UI 반영 시 Mission 엔티티에 추가
  static let stubSettledAt: String? = nil
  // TODO: disputeReason UI 반영 시 Mission 엔티티에 추가
  static let stubDisputeReason: String? = nil
  // TODO: createdAt UI 반영 시 Mission 엔티티에 추가
  static let stubCreatedAt: String = ""
}
