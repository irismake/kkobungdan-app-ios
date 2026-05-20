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

  func createProposal(title: String, content: String, deadline: String, errandFee: String) async throws -> Proposal {
    let dto: ProposalResponseDTO = try await client.post(
      "/v1/proposal",
      body: ProposalCreateBody(title: title, content: content, deadline: deadline, errandFee: Int(errandFee) ?? 0)
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
}
