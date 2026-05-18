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
  let title: String
  let content: String
  let deadline: String
  let meetingAt: String?
  let errandFee: Int
  let itemPrice: Int?
  let deposit: Int?
  let status: String
  let offers: [OfferResponseDTO]?
}

extension MyProposalResponseDTO {
  func toDomain() -> MyProposal {
    MyProposal(
      id: id,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      meetingAt: meetingAt.map(DateFormatters.parse),
      errandFee: errandFee,
      itemPrice: itemPrice,
      deposit: deposit,
      status: ProposalStatus(rawValue: status) ?? .posted,
      offers: offers?.map { $0.toDomain() } ?? []
    )
  }
}
