//
//  ProposalDetailResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/22/26.
//

import Foundation

struct ProposalDetailResponseDTO: Decodable {
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

extension ProposalDetailResponseDTO {
  func toDomain() -> ProposalDetail {
    ProposalDetail(
      id: id,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      meetingAt: DateFormatters.parse(meetingAt),
      errandFee: errandFee,
      itemPrice: itemPrice,
      deposit: deposit,
      status: ProposalStatus(rawValue: status) ?? .holding
    )
  }
}
