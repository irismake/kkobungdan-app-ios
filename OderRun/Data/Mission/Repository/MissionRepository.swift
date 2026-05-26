//
//  MissionRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

struct MissionActionBody: Encodable {
  let action: String
  // TODO: proofImageUrl — COMPLETE_DELIVERY UI 연동 전까지 stub 값 전송
  let proofImageUrl: String? = MissionActionBody.stubProofImageUrl
  // TODO: disputeReason — DISPUTE UI 연동 전까지 stub 값 전송
  let disputeReason: String? = MissionActionBody.stubDisputeReason
}

extension MissionActionBody {
  // TODO: proofImageUrl UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubProofImageUrl: String? = nil
  // TODO: disputeReason UI 반영 시 호출부에서 실제 값 전달로 교체
  static let stubDisputeReason: String? = nil
}

final class MissionRepository: MissionRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  func fetchMissionByProposal(proposalID: Int64) async throws -> Mission? {
    do {
      let dto: MissionResponseDTO =
        try await client.get("/v1/mission", params: ["proposalId": proposalID])
      return dto.toDomain()
    } catch RepositoryError.notFound {
      return nil
    }
  }

  func fetchMissionByOffer(offerID: Int64) async throws -> Mission? {
    do {
      let dto: MissionResponseDTO =
        try await client.get("/v1/mission", params: ["offerId": offerID])
      return dto.toDomain()
    } catch RepositoryError.notFound {
      return nil
    }
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission {
    let dto: MissionResponseDTO = try await client.put(
      "/v1/mission/\(id)",
      body: MissionActionBody(action: action.rawValue, proofImageUrl: proofImageURL, disputeReason: disputeReason)
    )
    return dto.toDomain()
  }
}
