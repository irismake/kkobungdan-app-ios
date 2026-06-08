//
//  ActivityRepositoryProtocol.swift
//  OderRun
//
//  Created by 김가희 on 5/13/26.
//

import Foundation

protocol ActivityRepositoryProtocol: Sendable {
  /// 현재 로그인한 오더(orderer)가 작성한 Proposal 목록 (`GET /v1/proposal/own`).
  /// 각 Proposal 에는 연결된 Offer 목록과 Offer 상태가 함께 포함된다.
  /// `status` 다중값 필터(`status=A&status=B`), 빈 배열이면 전체 상태.
  func fetchMyProposals(
    status: [ProposalStatus],
    page: Int,
    size: Int
  ) async throws -> [MyProposal]

  /// 현재 로그인한 러너(runner)가 제출한 Offer 목록 (`GET /v1/offer/own`).
  /// `status` 다중값 필터(`status=A&status=B`), 빈 배열이면 전체 상태.
  func fetchMyOffers(
    status: [OfferStatus],
    page: Int,
    size: Int
  ) async throws -> [MyOffer]
}
