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
  let title: String
  let content: String
  let deadline: String
  let meetingAt: String?
  let errandFee: Int
  let itemPrice: Int?
  let deposit: Int?
  let status: String
}

extension MyOfferResponseDTO {
  func toDomain() -> MyOffer {
    MyOffer(
      id: id,
      proposalID: proposalID,
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      meetingAt: meetingAt.map(DateFormatters.parse),
      errandFee: errandFee,
      itemPrice: itemPrice,
      deposit: deposit,
      status: OfferStatus(rawValue: status) ?? .waiting
    )
  }
}
