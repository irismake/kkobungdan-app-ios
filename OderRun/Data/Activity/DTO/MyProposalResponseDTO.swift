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
  let errandFee: Int
  let status: String
}

extension MyProposalResponseDTO {
  func toDomain() -> MyProposal {
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
