//
//  ApplyDetailViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class ApplyDetailViewModel {
  let proposalID: Int64
  let offerID: Int64

  var proposal: Proposal?
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

  /// 러너가 완료 처리를 마쳤고, 요청자(의뢰자) 확인을 기다리는 중인지 여부.
  var isWaitingForOrdererConfirm: Bool {
    offer?.status == .runnerCompleted
  }

  /// 매칭 전(WAITING) 지원만 취소할 수 있다. (디자인: "매칭되기 전에는 지원 취소 버튼 제공")
  var canCancelOffer: Bool {
    offer?.status == .waiting
  }

  private let fetchDetailUseCase: FetchProposalDetailUseCase
  private let fetchOfferDetailUseCase: FetchOfferDetailUseCase
  private let completeDeliveryUseCase: CompleteDeliveryUseCase
  private let cancelOfferUseCase: CancelOfferUseCase

  init(
    proposalID: Int64,
    offerID: Int64,
    fetchDetailUseCase: FetchProposalDetailUseCase,
    fetchOfferDetailUseCase: FetchOfferDetailUseCase,
    completeDeliveryUseCase: CompleteDeliveryUseCase,
    cancelOfferUseCase: CancelOfferUseCase
  ) {
    self.proposalID = proposalID
    self.offerID = offerID
    self.fetchDetailUseCase = fetchDetailUseCase
    self.fetchOfferDetailUseCase = fetchOfferDetailUseCase
    self.completeDeliveryUseCase = completeDeliveryUseCase
    self.cancelOfferUseCase = cancelOfferUseCase
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      let proposal = try await fetchDetailUseCase.execute(id: proposalID)
      self.proposal = proposal

      offer = try await fetchOfferDetailUseCase.execute(offerID: offerID)
    } catch {
      errorMessage = "지원 상세를 불러오지 못했어요."
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
      // TODO: proofImageUrl UI 연동 전까지 stub URL 전송.
      // let proofURL = "https://cdn.orderrun.com/proofs/offer-\(offerID).jpg"
      _ = try await completeDeliveryUseCase.execute(offerID: offerID, proofImageURL: nil)
      await load()
    } catch {
      errorMessage = "진행 완료 처리에 실패했어요. 잠시 후 다시 시도해주세요."
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
      didCancel = true
    } catch {
      errorMessage = "지원을 취소하지 못했어요."
    }
    isCancelling = false
  }
}
