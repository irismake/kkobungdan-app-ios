//
//  ProposalRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

final class ProposalRepositoryImpl: ProposalRepositoryProtocol, Sendable {
  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal {
    // TODO: 실제 API 연동 시 구현
    try await Task.sleep(nanoseconds: 1_000_000_000)

    return Proposal(
      id: Int64.random(in: 1 ... 9_999_999),
      title: title,
      content: content,
      deadline: DateFormatters.parse(deadline),
      errandFee: Int(errandFee) ?? 0,
      status: .posted
    )
  }
}
