//
//  OfferMessageViewModel.swift
//  Kkobungdan
//
//  지원 흐름 2단계: 첫 인사(지원 메시지) 작성 후 실제 지원(offer 생성).
//  (요청 상세 → 계좌 등록 → 첫 인사 → 지원 완료)
//

import Foundation

@Observable
final class OfferMessageViewModel: LoadableViewModel {
  static let maxMessageLength = 500

  let proposalID: Int64

  /// 상단 요청 요약 카드용.
  var proposal: ProposalDetail?
  var message: String = ""
  var isLoading: Bool = false
  var isOffering: Bool = false
  var errorMessage: String?

  private let fetchProposalDetailUseCase: FetchProposalDetailUseCase
  private let createOfferUseCase: CreateOfferUseCase

  init(
    proposalID: Int64,
    fetchProposalDetailUseCase: FetchProposalDetailUseCase,
    createOfferUseCase: CreateOfferUseCase
  ) {
    self.proposalID = proposalID
    self.fetchProposalDetailUseCase = fetchProposalDetailUseCase
    self.createOfferUseCase = createOfferUseCase
  }

  /// 메시지를 한 글자 이상 써야 지원할 수 있다.
  var canOffer: Bool {
    !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isOffering
  }

  @MainActor
  func load() async {
    await withLoading(fallback: "요청 정보를 불러오지 못했어요.") {
      proposal = try await fetchProposalDetailUseCase.execute(id: proposalID)
    }
  }

  /// 지원(offer 생성). 성공하면 생성된 offer ID 를, 실패하면 nil 을 반환한다.
  @MainActor
  func offer() async -> Int64? {
    guard canOffer else {
      return nil
    }
    isOffering = true
    errorMessage = nil
    defer { isOffering = false }
    do {
      // 지원 메시지는 서버가 대화방의 첫 채팅으로 넣는다.
      let offer = try await createOfferUseCase.execute(
        proposalID: proposalID,
        message: message.trimmingCharacters(in: .whitespacesAndNewlines)
      )
      return offer.id
    } catch {
      errorMessage = error.userMessage(fallback: "지원에 실패했어요. 잠시 후 다시 시도해주세요.")
      return nil
    }
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension OfferMessageViewModel {
  static func preview() -> OfferMessageViewModel {
    OfferMessageViewModel(
      proposalID: 1,
      fetchProposalDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      createOfferUseCase: CreateOfferUseCase(repository: DIContainer.offerRepository)
    )
  }
}
