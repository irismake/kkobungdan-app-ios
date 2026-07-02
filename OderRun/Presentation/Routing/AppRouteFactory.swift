//
//  AppRouteFactory.swift
//  OderRun
//
//  AppRoute 화면이 쓰는 ViewModel 을 DIContainer 로 조립한다.
//  더미 데이터 환경에서는 DIContainer 싱글턴 레포지토리를 그대로 사용해 in-memory 상태가 화면 간 공유된다.
//

import Foundation

enum AppRouteFactory {
  // MARK: - Proposal Detail (non-mine)

  static func makeProposalDetailViewModel(proposalID: Int64) -> ProposalDetailViewModel {
    ProposalDetailViewModel(
      proposalID: proposalID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOffersByProposalUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository)
    )
  }

  // MARK: - Report (의뢰 신고)

  static func makeReportViewModel(proposalID: Int64) -> ReportViewModel {
    ReportViewModel(
      proposalID: proposalID,
      fetchReasonsUseCase: FetchReportReasonsUseCase(repository: DIContainer.reportRepository),
      submitReportUseCase: SubmitProposalReportUseCase(repository: DIContainer.reportRepository)
    )
  }

  // MARK: - Mission Abort (임무 중단 — 분쟁 제기)

  static func makeMissionAbortViewModel(target: MissionAbortTarget) -> MissionAbortViewModel {
    let submitTarget: MissionAbortViewModel.Submit
    switch target {
    case let .proposal(proposalID):
      submitTarget = .proposal(
        proposalID: proposalID,
        useCase: RaiseProposalDisputeUseCase(repository: DIContainer.proposalRepository)
      )
    case let .offer(offerID):
      submitTarget = .offer(
        offerID: offerID,
        useCase: RaiseOfferDisputeUseCase(repository: DIContainer.offerRepository)
      )
    }
    return MissionAbortViewModel(
      submitTarget: submitTarget,
      fetchQuestionsUseCase: FetchDisputeSurveyQuestionsUseCase(
        repository: DIContainer.disputeSurveyRepository
      )
    )
  }

  // MARK: - Account Register (지원하기 → 계좌 등록)

  static func makeAddOfferViewModel(proposalID: Int64) -> AddOfferViewModel {
    AddOfferViewModel(
      proposalID: proposalID,
      account: makeSettlementAccountInputModel(),
      createOfferUseCase: CreateOfferUseCase(repository: DIContainer.offerRepository)
    )
  }

  // MARK: - My Proposal Detail (orderer)

  static func makeMyProposalDetailViewModel(proposalID: Int64) -> MyProposalDetailViewModel {
    MyProposalDetailViewModel(
      proposalID: proposalID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOffersUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository),
      confirmReceivedUseCase: ConfirmReceivedUseCase(repository: DIContainer.proposalRepository),
      cancelProposalUseCase: CancelProposalUseCase(repository: DIContainer.proposalRepository),
      fetchDisputeEvidenceUseCase: FetchDisputeEvidenceUseCase(repository: DIContainer.disputeEvidenceRepository)
    )
  }

  // MARK: - offer Detail (runner only)

  static func makeOfferDetailViewModel(
    proposalID: Int64,
    offerID: Int64
  ) -> OfferDetailViewModel {
    OfferDetailViewModel(
      proposalID: proposalID,
      offerID: offerID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOfferDetailUseCase: FetchOfferDetailUseCase(repository: DIContainer.offerRepository),
      completeDeliveryUseCase: CompleteDeliveryUseCase(repository: DIContainer.offerRepository),
      cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository),
      fetchDisputeEvidenceUseCase: FetchDisputeEvidenceUseCase(repository: DIContainer.disputeEvidenceRepository)
    )
  }

  // MARK: - Offer List

  static func makeOfferListViewModel(proposalID: Int64) -> OfferListViewModel {
    OfferListViewModel(
      proposalID: proposalID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOffersUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository),
      acceptOfferUseCase: AcceptOfferUseCase(repository: DIContainer.offerRepository)
    )
  }

  // MARK: - Add Proposal (Fee 단계에서 실제 등록 API 호출)

  static func makeAddProposalViewModel() -> AddProposalViewModel {
    AddProposalViewModel(
      createProposalUseCase: CreateProposalUseCase(repository: DIContainer.proposalRepository),
      account: makeSettlementAccountInputModel()
    )
  }

  // MARK: - 정산 계좌 입력 (공용 — offer·proposal 등에서 조합)

  static func makeSettlementAccountInputModel() -> SettlementAccountInputModel {
    SettlementAccountInputModel(
      fetchAccountUseCase: FetchSettlementAccountUseCase(settlementRepository: DIContainer.settlementRepository),
      saveAccountUseCase: SaveSettlementAccountUseCase(settlementRepository: DIContainer.settlementRepository),
      fetchBankNamesUseCase: FetchSettlementBankNamesUseCase(settlementRepository: DIContainer.settlementRepository)
    )
  }

  // MARK: - Verification (AuthRoute — 회원가입·로그인 인증번호 확인 공용)

  static func makeVerificationViewModel(
    flow: VerificationCodeViewModel.Flow
  ) -> VerificationCodeViewModel {
    let authRepository = DIContainer.authRepository
    return VerificationCodeViewModel(
      flow: flow,
      sendSignupCodeUseCase: SendSignupCodeUseCase(authRepository: authRepository),
      confirmSignupCodeUseCase: ConfirmSignupCodeUseCase(authRepository: authRepository),
      sendLoginCodeUseCase: SendLoginCodeUseCase(authRepository: authRepository),
      confirmLoginCodeUseCase: ConfirmLoginCodeUseCase(authRepository: authRepository)
    )
  }
}
