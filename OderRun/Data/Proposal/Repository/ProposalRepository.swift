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
  // TODO: meetingAt UI 연동 전까지 stub 값 전송
  let meetingAt: String = ProposalCreateBody.stubMeetingAt
  // TODO: itemPrice UI 연동 전까지 stub 값 전송
  let itemPrice: Int = ProposalCreateBody.stubItemPrice
  // TODO: deposit UI 연동 전까지 stub 값 전송
  let deposit: Int = ProposalCreateBody.stubDeposit
}

extension ProposalCreateBody {
  // TODO: meetingAt UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubMeetingAt: String = ""
  // TODO: itemPrice UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubItemPrice: Int = 0
  // TODO: deposit UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubDeposit: Int = 0
}

private struct ProposalUpdateBody: Encodable {
  let title: String
  let content: String
  let deadline: String
  let errandFee: Int
}

final class ProposalRepository: ProposalRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchProposals(page: Int, size: Int) async throws -> [Proposal] {
    let pageDTO: PageDTO<ProposalResponseDTO> =
      try await client.get("/v1/proposal", params: ["page": page, "size": size])
    return pageDTO.content.map { $0.toDomain() }
  }

  func fetchProposal(id: Int64) async throws -> Proposal {
    let dto: ProposalResponseDTO = try await client.get("/v1/proposal/\(id)")
    return dto.toDomain()
  }

  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: Int
  ) async throws -> ProposalDetail {
    let dto: ProposalDetailResponseDTO = try await client.post(
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
    let dto: ProposalCancelResponseDTO =
      try await client.post("/v1/proposal/\(id)/cancel", body: nil as String?)
    return dto.toDomain()
  }
}
