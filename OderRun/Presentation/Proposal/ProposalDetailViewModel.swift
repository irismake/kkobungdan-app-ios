//
//  ProposalDetailViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class ProposalDetailViewModel {
  let proposalID: Int64

  var proposal: ProposalDetail?
  var isLoading: Bool = false
  var errorMessage: String?
  var isOffering: Bool = false
  var hasApplied: Bool = false

  var isMine: Bool {
    guard let proposal else {
      return false
    }
    return proposal.ordererID == tokenStorage.userID
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let createOfferUseCase: CreateOfferUseCase
  private let fetchOffersByProposalUseCase: FetchOffersByProposalUseCase
  private let fetchSettlementAccountUseCase: FetchSettlementAccountUseCase
  private let tokenStorage: TokenStorage

  /// 지원하기 버튼을 눌렀을 때의 다음 단계.
  enum ApplyStep {
    /// 정산 계좌가 이미 있어 등록 화면 없이 바로 지원 완료.
    case applied
    /// 정산 계좌가 없어 계좌 등록 화면으로 이동해야 함.
    case needsAccount
    /// 조회·지원 실패.
    case failed
  }

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    createOfferUseCase: CreateOfferUseCase,
    fetchOffersByProposalUseCase: FetchOffersByProposalUseCase,
    fetchSettlementAccountUseCase: FetchSettlementAccountUseCase,
    tokenStorage: TokenStorage = .shared
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.createOfferUseCase = createOfferUseCase
    self.fetchOffersByProposalUseCase = fetchOffersByProposalUseCase
    self.fetchSettlementAccountUseCase = fetchSettlementAccountUseCase
    self.tokenStorage = tokenStorage
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      async let proposalTask = fetchDetailUseCase.execute(id: proposalID)
      async let offersTask = fetchOffersByProposalUseCase.execute(proposalID: proposalID)
      let (proposal, offers) = try await (proposalTask, offersTask)
      self.proposal = proposal
      let currentUserID = tokenStorage.userID
      hasApplied = offers.contains {
        $0.runnerID == currentUserID && ($0.status == .waiting || $0.status == .accepted)
      }
    } catch {
      errorMessage = "요청 상세를 불러오지 못했어요."
    }
    isLoading = false
  }

  /// 지원하기. 정산 계좌 유무로 분기한다.
  /// - 계좌 있음: 계좌 등록 화면 없이 바로 offer 를 생성하고 `.applied`.
  /// - 계좌 없음: offer 를 만들지 않고 `.needsAccount` (계좌 등록 화면으로 이동).
  @MainActor
  func onOffer() async -> Bool {
    guard !isOffering, !hasApplied else {
      return false
    }
    isOffering = true
    errorMessage = nil
    defer { isApplying = false }
    do {
      _ = try await createOfferUseCase.execute(proposalID: proposalID)
      hasApplied = true
      isOffering = false
      return true
    } catch {
      errorMessage = "지원에 실패했어요. 잠시 후 다시 시도해주세요."
      return .failed
    }
    isOffering = false
    return false
  }
}
