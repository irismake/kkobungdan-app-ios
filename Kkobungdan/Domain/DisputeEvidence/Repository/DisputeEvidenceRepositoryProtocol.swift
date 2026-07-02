//
//  DisputeEvidenceRepositoryProtocol.swift
//  Kkobungdan
//
//  Created by 김가희 on 7/2/26.
//

import Foundation

/// 분쟁 증빙 조회 대상. proposalID 또는 offerID 중 하나로 조회한다.
enum DisputeEvidenceQuery: Equatable {
  case proposal(Int64)
  case offer(Int64)
}

protocol DisputeEvidenceRepositoryProtocol: Sendable {
  /// 분쟁 증빙 상세 조회. `GET /v1/dispute-evidence?proposalId=` · `?offerId=`
  func fetchEvidence(for query: DisputeEvidenceQuery) async throws -> DisputeEvidence
}
