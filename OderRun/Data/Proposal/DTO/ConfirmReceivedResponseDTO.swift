//
//  ConfirmReceivedResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 6/11/26.
//
//  `POST /v1/proposal/{id}/confirm-received` 응답 DTO.
//  상세 응답과 달리 matchedAt·receivedConfirmedAt 가 포함되어 별도 타입으로 분리한다.
//

import Foundation

struct ConfirmReceivedResponseDTO: Decodable {
  let id: Int64
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
  let status: String
  let matchedAt: String
  let receivedConfirmedAt: String
  let offers: [ProposalOwnOfferResponseDTO]
}

extension ConfirmReceivedResponseDTO {
  func toDomain() -> Proposal {
    // TODO: matchedAt, receivedConfirmedAt, offers — UI 반영 시 Proposal 엔티티에 추가
    Proposal(
      id: id,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: errandFee,
      status: ProposalStatus(rawValue: status) ?? .posted
    )
  }
}
