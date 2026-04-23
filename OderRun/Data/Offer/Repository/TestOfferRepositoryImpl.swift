//
//  TestOfferRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

actor TestOfferRepositoryImpl: OfferRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  private var offers: [Offer] = Offer.dummyList
  private var nextID: Int64 = 1000

  func createOffer(proposalID: Int64) async throws -> Offer {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let duplicated = offers.contains {
      $0.proposalID == proposalID
        && $0.runnerID == DummySession.currentUserID
        && $0.status == .waiting
    }
    if duplicated {
      throw RepositoryError.conflict
    }
    let newID = nextID
    nextID += 1
    let offer = Offer(
      id: newID,
      proposalID: proposalID,
      runnerID: DummySession.currentUserID,
      status: .waiting,
      createdAt: Date()
    )
    offers.append(offer)
    return offer
  }

  func fetchOffersByProposal(proposalID: Int64) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    return offers
      .filter { $0.proposalID == proposalID }
      .sorted { $0.createdAt > $1.createdAt }
  }

  func fetchMyOffers(status: OfferStatus?, page: Int, size: Int) async throws -> [Offer] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let mine = offers.filter { $0.runnerID == DummySession.currentUserID }
    let filtered = status.map { s in mine.filter { $0.status == s } } ?? mine
    let start = page * size
    guard start < filtered.count else {
      return []
    }
    return Array(filtered[start ..< min(start + size, filtered.count)])
  }

  func cancelOffer(offerID: Int64) async throws {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = offers.firstIndex(where: { $0.id == offerID }) else {
      throw RepositoryError.notFound
    }
    guard offers[index].status == .waiting else {
      throw RepositoryError.conflict
    }
    let existing = offers[index]
    offers[index] = Offer(
      id: existing.id,
      proposalID: existing.proposalID,
      runnerID: existing.runnerID,
      status: .cancelled,
      createdAt: existing.createdAt
    )
  }
}
