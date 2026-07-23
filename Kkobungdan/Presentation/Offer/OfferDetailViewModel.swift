//
//  OfferDetailViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class OfferDetailViewModel {
  let proposalID: Int64
  let offerID: Int64

  var proposal: ProposalDetail?
  var isLoading: Bool = false
  var errorMessage: String?

  var offer: OfferDetail?
  var isCompletingDelivery: Bool = false
  var isCancelling: Bool = false
  var didCancel: Bool = false

  /// "만났어요!"(배달 완료) 버튼 노출 여부.
  /// 내 offer 가 ACCEPTED.
  var canCompleteDelivery: Bool {
    offer?.status == .accepted
  }

  /// 카카오톡 오픈채팅방 링크. offer 가 ACCEPTED·RUNNER_COMPLETED 일 때만 노출한다.
  var openChatURL: String? {
    guard let offer, offer.status == .accepted || offer.status == .runnerCompleted else {
      return nil
    }
    return offer.openChatURL
  }

  /// 러너가 완료 처리를 마쳤고, 요청자(의뢰자) 확인을 기다리는 중인지 여부.
  var isWaitingForOrdererConfirm: Bool {
    offer?.status == .runnerCompleted
  }

  /// 매칭 전(WAITING) 지원만 취소할 수 있다. (디자인: "매칭되기 전에는 지원 취소 버튼 제공")
  var canCancelOffer: Bool {
    offer?.status == .waiting
  }

  /// 분쟁 중 조회한 증빙. 내가 중단을 신청한 당사자인지 판별하는 데 쓴다.
  var disputeEvidence: DisputeEvidence?

  /// 분쟁 중이고 중단을 신청한 당사자가 내가 아닌 경우(= 내가 중단을 당한 경우) → 문의하기 노출.
  /// 이 화면은 러너 본인의 지원 상세이므로 내 식별자는 `offer.runnerID`.
  var isDisputedByCounterparty: Bool {
    guard offer?.status == .disputed,
          let evidence = disputeEvidence,
          let runnerID = offer?.runnerID
    else {
      return false
    }
    return evidence.actorID != runnerID
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOfferDetailUseCase: FetchOfferDetailUseCase
  private let completeDeliveryUseCase: CompleteDeliveryUseCase
  private let cancelOfferUseCase: CancelOfferUseCase
  private let fetchDisputeEvidenceUseCase: FetchDisputeEvidenceUseCase

  init(
    proposalID: Int64,
    offerID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOfferDetailUseCase: FetchOfferDetailUseCase,
    completeDeliveryUseCase: CompleteDeliveryUseCase,
    cancelOfferUseCase: CancelOfferUseCase,
    fetchDisputeEvidenceUseCase: FetchDisputeEvidenceUseCase
  ) {
    self.proposalID = proposalID
    self.offerID = offerID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOfferDetailUseCase = fetchOfferDetailUseCase
    self.completeDeliveryUseCase = completeDeliveryUseCase
    self.cancelOfferUseCase = cancelOfferUseCase
    self.fetchDisputeEvidenceUseCase = fetchDisputeEvidenceUseCase
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let proposal = try await fetchDetailUseCase.execute(id: proposalID)
      self.proposal = proposal

      let offer = try await fetchOfferDetailUseCase.execute(offerID: offerID)
      self.offer = offer

      // 분쟁 중일 때만 증빙을 조회해 신청자/피신청자를 분기한다.
      // 증빙 조회 실패는 상세 로딩을 막지 않도록 보조 정보로만 취급한다.
      if offer.status == .disputed {
        disputeEvidence = try? await fetchDisputeEvidenceUseCase.execute(for: .offer(offerID))
      } else {
        disputeEvidence = nil
      }
    } catch {
      errorMessage = error.userMessage(fallback: "지원 상세를 불러오지 못했어요.")
    }
    isLoading = false
  }

  /// 러너 배달 완료. `POST /v1/offer/{id}/complete-delivery`
  @MainActor
  func completeDelivery() async {
    guard canCompleteDelivery, !isCompletingDelivery else {
      return
    }
    isCompletingDelivery = true
    errorMessage = nil
    do {
      _ = try await completeDeliveryUseCase.execute(offerID: offerID)
      await load()
    } catch {
      errorMessage = error.userMessage(fallback: "임무 완료 처리에 실패했어요. 잠시 후 다시 시도해주세요.")
    }
    isCompletingDelivery = false
  }

  /// 러너가 본인 지원(WAITING)을 취소한다. 성공 시 `didCancel` 을 올려 화면을 닫는다.
  @MainActor
  func cancelOffer() async {
    guard canCancelOffer, !isCancelling else {
      return
    }
    isCancelling = true
    errorMessage = nil
    do {
      try await cancelOfferUseCase.execute(offerID: offerID)
      NotificationCenter.default.post(name: .proposalListNeedsRefresh, object: nil)
      didCancel = true
    } catch {
      errorMessage = error.userMessage(fallback: "지원을 취소하지 못했어요.")
    }
    isCancelling = false
  }
}
