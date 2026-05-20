//
//  ProposalResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//
//  NOTE: ordererID 는 공식 스펙 밖 필드. 서버 응답에 없으면 nil 로 디코딩된다.
//

import Foundation

struct ProposalResponseDTO: Decodable {
  let id: Int64
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
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: errandFee,
      status: ProposalStatus(rawValue: status) ?? .posted
    )
  }
}
