//
//  ProposalResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  NOTE: ordererID 는 공식 스펙 밖 필드. 서버 응답이 확정되면 일치시킨다.
//

import Foundation

struct ProposalResponseDTO: Decodable {
  let id: Int64
  let ordererID: String
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
  let status: String
}

extension ProposalResponseDTO {
  func toDomain() -> Proposal {
    Proposal(
      id: id,
      ordererID: ordererID,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: errandFee,
      status: ProposalStatus(rawValue: status) ?? .posted
    )
  }
}
