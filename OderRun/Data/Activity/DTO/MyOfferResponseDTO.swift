//
//  MyOfferResponseDTO.swift
//  OderRun
//
//  Created by 김가희 on 5/18/26.
//
//  /v1/offer/own 응답 항목 DTO.
//

import Foundation

struct MyOfferResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let runnerName: String
  let status: String
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case runnerName
    case status
    case createdAt
  }
}

extension MyOfferResponseDTO {
  func toDomain() -> MyOffer {
    MyOffer(
      id: id,
      proposalID: proposalID,
      runnerName: runnerName,
      status: OfferStatus(rawValue: status) ?? .waiting,
      createdAt: DateFormatters.parse(createdAt),
      // TODO: 서버에서 title/content/deadline/errandFee/meetingAt/itemPrice/deposit 필드 추가되면 교체
      title: "",
      content: "",
      deadline: DateFormatters.parse(createdAt),
      meetingAt: nil,
      errandFee: 0,
      itemPrice: nil,
      deposit: nil
    )
  }
}
