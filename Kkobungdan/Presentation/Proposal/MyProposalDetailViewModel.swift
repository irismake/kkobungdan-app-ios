//
//  MyProposalDetailViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class MyProposalDetailViewModel: LoadableViewModel {
  let proposalID: Int64

  var proposal: ProposalDetail?
  var offers: [Offer] = []
  var isLoading: Bool = false
  var errorMessage: String?
  var isCancelling: Bool = false
  var didCancel: Bool = false
  var isConfirming: Bool = false

  /// "만났어요!"(수령 확인) 버튼 노출 여부.
  /// proposal 이 MATCHED.
  var canConfirmReceived: Bool {
    proposal?.status == .matched
  }

  /// 카카오톡 오픈채팅방 링크. proposal 이 MATCHED·ORDER_COMPLETED 일 때만 노출한다.
  var openChatURL: String? {
    guard let proposal, proposal.status == .matched || proposal.status == .orderCompleted else {
      return nil
    }
    return proposal.openChatURL
  }

  /// 오더러가 수령 확인을 마쳤고, 러너 완료 처리를 기다리는 중인지 여부.
  var isWaitingForRunnerConfirm: Bool {
    proposal?.status == .orderCompleted
  }

  var runnerCount: Int {
    offers.filter { $0.status == .waiting || $0.status == .accepted }.count
  }

  /// 매칭된 offer. 진행중·완료·분쟁중 proposal 의 매칭 러너 카드 표시에 사용.
  var matchedOffer: Offer? {
    offers.first(where: {
      $0.status == .accepted || $0.status == .runnerCompleted
        || $0.status == .allCompleted || $0.status == .disputed
    })
  }

  /// 분쟁 중 조회한 증빙. 내가 중단을 신청한 당사자인지 판별하는 데 쓴다.
  /// 관련 대화에 보일 지원자. 미션이 생성된 뒤(선택된 지원자가 있을 때)에만 채워진다.
  /// 선택된 지원자 먼저, 그다음 선택되지 않은(rejected) 지원자.
  var relatedChatOffers: [Offer] {
    guard let matchedOffer else {
      return []
    }
    return [matchedOffer] + offers.filter { $0.status == .rejected }
  }

  var disputeEvidence: DisputeEvidence?

  /// 분쟁 중이고 중단을 신청한 당사자가 내가 아닌 경우(= 내가 중단을 당한 경우) → 문의하기 노출.
  /// 이 화면은 오더러 본인의 요청 상세이므로 내 식별자는 `proposal.ordererID`.
  var isDisputedByCounterparty: Bool {
    guard proposal?.status == .disputed,
          let evidence = disputeEvidence,
          let ordererID = proposal?.ordererID
    else {
      return false
    }
    return evidence.actorID != ordererID
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOffersUseCase: FetchOffersByProposalUseCase
  private let confirmReceivedUseCase: ConfirmReceivedUseCase
  private let cancelProposalUseCase: CancelProposalUseCase
  private let fetchDisputeEvidenceUseCase: FetchDisputeEvidenceUseCase

  init(
    proposalID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOffersUseCase: FetchOffersByProposalUseCase,
    confirmReceivedUseCase: ConfirmReceivedUseCase,
    cancelProposalUseCase: CancelProposalUseCase,
    fetchDisputeEvidenceUseCase: FetchDisputeEvidenceUseCase
  ) {
    self.proposalID = proposalID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOffersUseCase = fetchOffersUseCase
    self.confirmReceivedUseCase = confirmReceivedUseCase
    self.cancelProposalUseCase = cancelProposalUseCase
    self.fetchDisputeEvidenceUseCase = fetchDisputeEvidenceUseCase
  }

  /// proposal 상태별로 조회할 offer status 필터.
  /// 미입금(HOLDING)·종료(취소/환불) 상태는 offer 목록을 조회하지 않으므로 `nil`.
  private func offerStatusFilter(for status: ProposalStatus) -> [OfferStatus]? {
    switch status {
    case .holding, .cancelled, .refundPending, .refunded:
      return nil
    case .posted, .offered:
      return [.waiting]
    case .matched, .orderCompleted:
      return [.accepted, .runnerCompleted]
    case .allCompleted:
      return [.allCompleted]
    case .disputed:
      return [.disputed]
    }
  }

  @MainActor
  func load() async {
    await withLoading(fallback: "내 요청 상세를 불러오지 못했어요.") {
      // offer 조회 status 필터가 proposal 상태에 의존하므로 proposal 을 먼저 조회한다.
      let loaded = try await fetchDetailUseCase.execute(id: proposalID)
      proposal = loaded

      if let filter = offerStatusFilter(for: loaded.status) {
        offers = try await fetchOffersUseCase.execute(proposalID: proposalID, status: filter)
      } else {
        offers = []
      }

      // 분쟁 중일 때만 증빙을 조회해 신청자/피신청자를 분기한다.
      // 증빙 조회 실패는 상세 로딩을 막지 않도록 보조 정보로만 취급한다.
      if loaded.status == .disputed {
        disputeEvidence = try? await fetchDisputeEvidenceUseCase.execute(for: .proposal(proposalID))
      } else {
        disputeEvidence = nil
      }
    }
  }

  /// 오더 수령 확인. `POST /v1/proposal/{id}/confirm-received`
  @MainActor
  func confirmReceived() async {
    guard canConfirmReceived, !isConfirming else {
      return
    }
    isConfirming = true
    errorMessage = nil
    do {
      _ = try await confirmReceivedUseCase.execute(proposalID: proposalID)
      await load()
    } catch {
      errorMessage = error.userMessage(fallback: "진행 완료 처리에 실패했어요. 잠시 후 다시 시도해주세요.")
    }
    isConfirming = false
  }

  @MainActor
  func cancelProposal() async {
    guard !isCancelling else {
      return
    }
    isCancelling = true
    errorMessage = nil
    do {
      // 취소 응답(Proposal)은 화면을 닫기 때문에 보관하지 않는다. 상세는 ProposalDetail 로 별도 조회.
      _ = try await cancelProposalUseCase.execute(id: proposalID)
      NotificationCenter.default.post(name: .proposalListNeedsRefresh, object: nil)
      didCancel = true
    } catch {
      errorMessage = error.userMessage(fallback: "요청을 취소하지 못했어요.")
    }
    isCancelling = false
  }
}
