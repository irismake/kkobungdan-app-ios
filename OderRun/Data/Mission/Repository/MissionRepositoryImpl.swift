//
//  MissionRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor MissionRepositoryImpl: MissionRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  private var missions: [MissionResponseDTO] = [
    // 내가 ORDERER — 진행 중 (proposal 5, offer 40 수락)
    .init(
      id: 100,
      offerID: 40,
      proposalID: 5,
      ordererID: DummySession.currentUserID,
      runnerID: "user-r002",
      status: "IN_PROGRESS",
      runFee: 8000,
      itemPrice: 23000,
      proofImageURL: nil,
      createdAt: "2026-04-22T12:00:00"
    ),
    // 내가 RUNNER — 전달 완료, 수령 대기 중 (proposal 4 의 러너 입장)
    .init(
      id: 101,
      offerID: 30,
      proposalID: 4,
      ordererID: "user-a001",
      runnerID: DummySession.currentUserID,
      status: "DELIVERY_COMPLETED",
      runFee: 2500,
      itemPrice: 0,
      proofImageURL: "https://cdn.orderrun.com/proofs/mission-101.jpg",
      createdAt: "2026-04-20T16:30:00"
    ),
    // 내가 ORDERER — 완료된 mission
    .init(
      id: 102,
      offerID: 9001,
      proposalID: 998,
      ordererID: DummySession.currentUserID,
      runnerID: "user-r001",
      status: "RECEIVED_CONFIRMED",
      runFee: 5000,
      itemPrice: 15000,
      proofImageURL: "https://cdn.orderrun.com/proofs/mission-102.jpg",
      createdAt: "2026-04-18T10:00:00"
    ),
    // 내가 RUNNER — 분쟁 케이스
    .init(
      id: 103,
      offerID: 9002,
      proposalID: 999,
      ordererID: "user-a002",
      runnerID: DummySession.currentUserID,
      status: "DISPUTED",
      runFee: 3000,
      itemPrice: 0,
      proofImageURL: nil,
      createdAt: "2026-04-15T11:00:00"
    )
  ]

  private var nextID: Int64 = 1000

  func createMission(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> Mission {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    if missions.contains(where: { $0.offerID == offerID }) {
      throw RepositoryError.conflict
    }
    let newID = nextID
    nextID += 1
    let dto = MissionResponseDTO(
      id: newID,
      offerID: offerID,
      proposalID: 0,
      ordererID: DummySession.currentUserID,
      runnerID: "user-r001",
      status: MissionStatus.created.rawValue,
      runFee: runFee,
      itemPrice: itemPrice,
      proofImageURL: nil,
      createdAt: DateFormatters.format(Date())
    )
    missions.append(dto)
    return dto.toDomain()
  }

  func fetchMyMissions(
    role: MissionRole?,
    status: MissionStatus?,
    page: Int,
    size: Int
  ) async throws -> [Mission] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let resolvedRole = role ?? .orderer
    let mine = missions.filter {
      switch resolvedRole {
      case .orderer:
        return $0.ordererID == DummySession.currentUserID
      case .runner:
        return $0.runnerID == DummySession.currentUserID
      }
    }
    let filtered = status.map { status in mine.filter { $0.status == status.rawValue } } ?? mine
    let start = page * size
    guard start < filtered.count else {
      return []
    }
    let end = min(start + size, filtered.count)
    return filtered[start ..< end].map { $0.toDomain() }
  }

  func updateMissionAction(
    id: Int64,
    action: MissionAction,
    proofImageURL: String?,
    disputeReason _: String?
  ) async throws -> Mission {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = missions.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = missions[index]
    let nextStatus: String
    switch action {
    case .startProgress:
      guard existing.status == MissionStatus.created.rawValue else {
        throw RepositoryError.conflict
      }
      nextStatus = MissionStatus.inProgress.rawValue
    case .completeDelivery:
      guard existing.status == MissionStatus.inProgress.rawValue,
            proofImageURL != nil
      else {
        throw RepositoryError.conflict
      }
      nextStatus = MissionStatus.deliveryCompleted.rawValue
    case .confirmReceived:
      guard existing.status == MissionStatus.deliveryCompleted.rawValue else {
        throw RepositoryError.conflict
      }
      nextStatus = MissionStatus.receivedConfirmed.rawValue
    case .dispute:
      nextStatus = MissionStatus.disputed.rawValue
    }
    let updated = MissionResponseDTO(
      id: existing.id,
      offerID: existing.offerID,
      proposalID: existing.proposalID,
      ordererID: existing.ordererID,
      runnerID: existing.runnerID,
      status: nextStatus,
      runFee: existing.runFee,
      itemPrice: existing.itemPrice,
      proofImageURL: proofImageURL ?? existing.proofImageURL,
      createdAt: existing.createdAt
    )
    missions[index] = updated
    return updated.toDomain()
  }
}
