//
//  ProposalCancelResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/26/26.
//

import Foundation

struct ProposalCancelResponseDTO: Decodable {
  let id: Int64
  let title: String
  let content: String
  let deadline: String
  let meetingAt: String
  let errandFee: Int
  let itemPrice: Int
  let deposit: Int
  let status: String
}

extension ProposalCancelResponseDTO {
  func toDomain() -> Proposal {
    // TODO: meetingAt, itemPrice, deposit — UI 반영 시 엔티티에 추가
    Proposal(
      id: id,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: errandFee,
      status: ProposalStatus(rawValue: status) ?? .cancelled
    )
  }

  // TODO: meetingAt UI 반영 시 Proposal 엔티티에 추가
  static let stubMeetingAt: String = ""
  // TODO: itemPrice UI 반영 시 Proposal 엔티티에 추가
  static let stubItemPrice: Int = 0
  // TODO: deposit UI 반영 시 Proposal 엔티티에 추가
  static let stubDeposit: Int = 0
}
