//
//  ProposalRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

private struct ProposalCreateBody: Encodable {
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
}

private struct ProposalUpdateBody: Encodable {
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
}

/// `POST /v1/proposal/{id}/dispute` 요청 바디. disputeReason 은 서버 required. (서버: `DisputeRequest`)
private struct DisputeRequest: Encodable {
  // TODO: surveyQuestionID — 분쟁 설문 UI 연동 전까지 stub 값 전송
  let surveyQuestionID: Int = DisputeRequest.stubSurveyQuestionID
  let disputeReason: String

  enum CodingKeys: String, CodingKey {
    case surveyQuestionID = "surveyQuestionId"
    case disputeReason
  }

  // TODO: surveyQuestionID UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubSurveyQuestionID: Int = 0
}

final class ProposalRepository: ProposalRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchProposals(status: [ProposalStatus], page: Int, size: Int) async throws -> [Proposal] {
    var params: [String: Any] = ["page": page, "size": size]
    if !status.isEmpty {
      params["status"] = status.map(\.rawValue)
    }
    let pageDTO: PageDTO<ProposalResponseDTO> =
      try await client.get("/v1/proposal", params: params)
    return pageDTO.content.map { $0.toDomain() }
  }

  func fetchProposal(id: Int64) async throws -> ProposalDetail {
    let dto: ProposalDetailResponseDTO = try await client.get("/v1/proposal/\(id)")
    return dto.toDomain()
  }

  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: Int
  ) async throws -> Proposal {
    let dto: ProposalResponseDTO = try await client.post(
      "/v1/proposal",
      body: ProposalCreateBody(
        title: title,
        content: content,
        deadline: deadline,
        errandFee: errandFee
      )
    )
    return dto.toDomain()
  }

  func updateProposal(id: Int64, title: String, content: String, deadline: String, errandFee: String) async throws -> Proposal {
    let dto: ProposalResponseDTO = try await client.put(
      "/v1/proposal/\(id)",
      body: ProposalUpdateBody(title: title, content: content, deadline: deadline, errandFee: Int(errandFee) ?? 0)
    )
    return dto.toDomain()
  }

  func cancelProposal(id: Int64) async throws -> Proposal {
    let dto: ProposalResponseDTO =
      try await client.post("/v1/proposal/\(id)/cancel", body: nil as String?)
    return dto.toDomain()
  }

  func confirmReceived(proposalID: Int64) async throws -> ProposalDetail {
    // confirm-received·dispute 모두 상세조회와 동일한 ProposalDetailResponse 를 반환한다.
    let dto: ProposalDetailResponseDTO =
      try await client.post("/v1/proposal/\(proposalID)/confirm-received", body: nil as String?)
    return dto.toDomain()
  }

  func raiseDispute(proposalID: Int64, reason: String) async throws -> ProposalDetail {
    let dto: ProposalDetailResponseDTO = try await client.post(
      "/v1/proposal/\(proposalID)/dispute",
      body: DisputeRequest(disputeReason: reason)
    )
    return dto.toDomain()
  }
}
