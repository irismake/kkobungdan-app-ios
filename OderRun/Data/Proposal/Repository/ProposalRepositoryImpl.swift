//
//  ProposalRepositoryImpl.swift
//  OderRun
//
//  Created by 김가희 on 3/9/26.
//

import Foundation

actor ProposalRepositoryImpl: ProposalRepositoryProtocol {
  private static let simulatedLatency: UInt64 = 700_000_000

  private var proposals: [ProposalResponseDTO] = [
    .init(
      id: 1,
      ordererID: "user-a001",
      title: "편의점 장보기 부탁",
      content: "GS25 에서 저지방 우유 1L 와 식빵을 사서 아파트 경비실에 맡겨 주세요.",
      deadline: "2026-04-24T15:30:00",
      errandFee: 4000,
      status: "POSTED"
    ),
    .init(
      id: 2,
      ordererID: "user-a002",
      title: "강아지 산책 대신",
      content: "주말에 30 분 정도 강아지와 산책해 주세요. 산책로는 한강공원 이촌지구입니다.",
      deadline: "2026-04-25T10:00:00",
      errandFee: 10000,
      status: "OFFERED"
    ),
    .init(
      id: 3,
      ordererID: DummySession.currentUserID,
      title: "약국에서 약 수령",
      content: "온누리약국에서 미리 주문한 처방전 받은 약을 대신 수령해 주세요.",
      deadline: "2026-04-23T18:00:00",
      errandFee: 3500,
      status: "OFFERED"
    ),
    .init(
      id: 4,
      ordererID: "user-a001",
      title: "택배 맡기기",
      content: "문 앞에 둔 택배 상자 2 개를 CU 편의점에 맡겨 주세요.",
      deadline: "2026-04-22T20:00:00",
      errandFee: 2500,
      status: "MATCHED"
    ),
    .init(
      id: 5,
      ordererID: DummySession.currentUserID,
      title: "저녁 식사 픽업",
      content: "교대역 쉐이크쉑 치즈버거 세트 2 개 픽업 후 자택으로 배달 부탁드립니다.",
      deadline: "2026-04-22T19:30:00",
      errandFee: 8000,
      status: "MATCHED"
    ),
    .init(
      id: 6,
      ordererID: "user-a002",
      title: "서류 전달",
      content: "강남구청 민원실에 서류 1 건 제출해 주세요. 번호표 대기 필요.",
      deadline: "2026-04-21T16:00:00",
      errandFee: 5000,
      status: "CANCELLED"
    ),
    .init(
      id: 7,
      ordererID: DummySession.currentUserID,
      title: "장미꽃 구매 배달",
      content: "꽃시장 근처에서 빨간 장미 20 송이 구매 후 회사로 배달 부탁드립니다.",
      deadline: "2026-04-26T14:00:00",
      errandFee: 6000,
      status: "POSTED"
    )
  ]

  private var nextID: Int64 = 100

  func fetchProposals(page: Int, size: Int) async throws -> [Proposal] {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let start = page * size
    guard start < proposals.count else {
      return []
    }
    let end = min(start + size, proposals.count)
    return proposals[start ..< end].map { $0.toDomain() }
  }

  func fetchProposal(id: Int64) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let dto = proposals.first(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    return dto.toDomain()
  }

  func createProposal(
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    let newID = nextID
    nextID += 1
    let dto = ProposalResponseDTO(
      id: newID,
      ordererID: DummySession.currentUserID,
      title: title,
      content: content,
      deadline: deadline,
      errandFee: Int(errandFee) ?? 0,
      status: ProposalStatus.posted.rawValue
    )
    proposals.insert(dto, at: 0)
    return dto.toDomain()
  }

  func updateProposal(
    id: Int64,
    title: String,
    content: String,
    deadline: String,
    errandFee: String
  ) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = proposals.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = proposals[index]
    guard existing.status == "POSTED" || existing.status == "OFFERED" else {
      throw RepositoryError.conflict
    }
    let updated = ProposalResponseDTO(
      id: existing.id,
      ordererID: existing.ordererID,
      title: title,
      content: content,
      deadline: deadline,
      errandFee: Int(errandFee) ?? existing.errandFee,
      status: existing.status
    )
    proposals[index] = updated
    return updated.toDomain()
  }

  func cancelProposal(id: Int64) async throws -> Proposal {
    try await Task.sleep(nanoseconds: Self.simulatedLatency)
    guard let index = proposals.firstIndex(where: { $0.id == id }) else {
      throw RepositoryError.notFound
    }
    let existing = proposals[index]
    guard existing.status == "POSTED" || existing.status == "OFFERED" else {
      throw RepositoryError.conflict
    }
    let updated = ProposalResponseDTO(
      id: existing.id,
      ordererID: existing.ordererID,
      title: existing.title,
      content: existing.content,
      deadline: existing.deadline,
      errandFee: existing.errandFee,
      status: ProposalStatus.cancelled.rawValue
    )
    proposals[index] = updated
    return updated.toDomain()
  }
}
