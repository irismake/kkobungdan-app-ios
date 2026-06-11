//
//  MyProposalResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  /v1/proposal/own 응답 항목 DTO.
//

import Foundation

struct MyProposalResponseDTO: Decodable {
  let id: Int64
  let ordererID: String
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
  let status: String
  let offerCount: Int
  let offers: [ProposalOwnOfferResponseDTO]
  let createdAt: String
  let updatedAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case ordererID = "ordererId"
    case title
    case content
    case deadline
    case errandFee
    case status
    case offerCount
    case offers
    case createdAt
    case updatedAt
  }
}

extension MyProposalResponseDTO {
  func toDomain() -> MyProposal {
    // TODO: ordererId, offerCount, offers, createdAt, updatedAt — UI 반영 시 MyProposal 엔티티에 추가.
    MyProposal(
      id: id,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: errandFee,
      status: ProposalStatus(rawValue: status) ?? .posted
    )
  }
}
