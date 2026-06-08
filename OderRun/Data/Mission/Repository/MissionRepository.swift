//
//  MissionRepository.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

/// `POST /v1/mission/{id}/complete-delivery` 요청 바디. proofImageUrl 은 서버 optional.
private struct CompleteDeliveryBody: Encodable {
  let proofImageUrl: String?
}

/// `POST /v1/mission/{id}/dispute` 요청 바디. disputeReason 은 서버 required.
private struct DisputeBody: Encodable {
  let disputeReason: String
}

final class MissionRepository: MissionRepositoryProtocol {
  private let client: HTTPClient

  init(client: HTTPClient = .shared) {
    self.client = client
  }

  /// `GET /v1/mission` 은 페이지 응답(`data.content[]`)이므로 첫 미션만 도메인으로 변환한다.
  func fetchMissionByProposal(proposalID: Int64) async throws -> Mission? {
    do {
      let page: PageDTO<MissionResponseDTO> =
        try await client.get("/v1/mission", params: ["proposalId": proposalID])
      return page.content.first?.toDomain()
    } catch RepositoryError.notFound {
      return nil
    }
  }

  func fetchMissionByOffer(offerID: Int64) async throws -> Mission? {
    do {
      let page: PageDTO<MissionResponseDTO> =
        try await client.get("/v1/mission", params: ["offerId": offerID])
      return page.content.first?.toDomain()
    } catch RepositoryError.notFound {
      return nil
    }
  }

  /// 행위별로 분리된 POST 엔드포인트로 미션 상태를 전이한다.
  /// (구 `PUT /v1/mission/{id}` 은 deprecated.)
  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason: String?
  ) async throws -> Mission {
    let dto: MissionResponseDTO
    switch action {
    case .completeDelivery:
      dto = try await client.post(
        "/v1/mission/\(id)/complete-delivery",
        body: CompleteDeliveryBody(proofImageUrl: proofImageURL)
      )
    case .confirmReceived:
      dto = try await client.post("/v1/mission/\(id)/confirm-received", body: nil as String?)
    case .dispute:
      dto = try await client.post(
        "/v1/mission/\(id)/dispute",
        body: DisputeBody(disputeReason: disputeReason ?? "")
      )
    }
    return dto.toDomain()
  }
}
