//
//  DisputeEvidenceResponseDTO.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/2/26.
//
//  `GET /v1/dispute-evidence` (분쟁 증빙 상세 조회) 응답 DTO.
//  (서버: `DisputeEvidenceResponse`)
//

import Foundation

struct DisputeEvidenceResponseDTO: Decodable {
  let id: Int64
  let proposalID: Int64
  let offerID: Int64
  let actorID: String
  let reason: String
  let surveyQuestionID: Int64
  let createdAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case proposalID = "proposalId"
    case offerID = "offerId"
    case actorID = "actorId"
    case reason
    case surveyQuestionID = "surveyQuestionId"
    case createdAt
  }
}

extension DisputeEvidenceResponseDTO {
  func toDomain() -> DisputeEvidence {
    DisputeEvidence(
      id: id,
      proposalID: proposalID,
      offerID: offerID,
      actorID: actorID,
      reason: reason,
      surveyQuestionID: surveyQuestionID,
      createdAt: DateFormatters.parse(createdAt)
    )
  }
}
