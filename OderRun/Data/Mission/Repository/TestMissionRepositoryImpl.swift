//
//  TestMissionRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor TestMissionRepositoryImpl: MissionRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  private var missions: [Mission] = Mission.dummyList
  private var nextID: Int64 = 1000

  func createMission(offerID: Int64, runFee: Int, itemPrice: Int) async throws -> Mission {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    if missions.contains(where: { $0.offerID == offerID }) {
      throw RepositoryError.conflict
    }
    guard let (offer, proposal) = try await resolveOfferAndProposal(offerID: offerID) else {
      throw RepositoryError.notFound
    }
    let newID = nextID
    nextID += 1
    let mission = Mission(
      id: newID, offerID: offerID, proposalID: offer.proposalID,
      ordererID: proposal.ordererID, runnerID: offer.runnerID,
      status: .created, runFee: runFee, itemPrice: itemPrice,
      proofImageURL: nil, createdAt: Date()
    )
    missions.append(mission)
    return mission
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
      case .orderer: return $0.ordererID == DummySession.currentUserID
      case .runner: return $0.runnerID == DummySession.currentUserID
      }
    }
    let filtered = status.map { s in mine.filter { $0.status == s } } ?? mine
    let start = page * size
    guard start < filtered.count else {
      return []
    }
    return Array(filtered[start ..< min(start + size, filtered.count)])
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
    let nextStatus: MissionStatus
    switch action {
    case .startProgress:
      guard existing.status == .created else {
        throw RepositoryError.conflict
      }
      nextStatus = .inProgress
    case .completeDelivery:
      guard existing.status == .inProgress, proofImageURL != nil else {
        throw RepositoryError.conflict
      }
      nextStatus = .deliveryCompleted
    case .confirmReceived:
      guard existing.status == .deliveryCompleted else {
        throw RepositoryError.conflict
      }
      nextStatus = .receivedConfirmed
    case .dispute:
      nextStatus = .disputed
    }
    let updated = Mission(
      id: existing.id, offerID: existing.offerID, proposalID: existing.proposalID,
      ordererID: existing.ordererID, runnerID: existing.runnerID,
      status: nextStatus, runFee: existing.runFee, itemPrice: existing.itemPrice,
      proofImageURL: proofImageURL ?? existing.proofImageURL,
      createdAt: existing.createdAt
    )
    missions[index] = updated
    return updated
  }

  private func resolveOfferAndProposal(offerID: Int64) async throws -> (Offer, Proposal)? {
    let proposals = try await DIContainer.proposalRepository.fetchProposals(page: 0, size: 1000)
    for proposal in proposals {
      let offers = try await DIContainer.offerRepository.fetchOffersByProposal(proposalID: proposal.id)
      if let offer = offers.first(where: { $0.id == offerID }) {
        return (offer, proposal)
      }
    }
    return nil
  }
}
