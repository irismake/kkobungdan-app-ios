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
      createOfferUseCase: CreateOfferUseCase(repository: DIContainer.offerRepository),
      fetchOffersByProposalUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository)
    )
  }

  // MARK: - Account Register (지원하기 → 계좌 등록)

  static func makeAccountRegisterViewModel(proposalID: Int64) -> AccountRegisterViewModel {
    AccountRegisterViewModel(
      proposalID: proposalID,
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
      cancelProposalUseCase: CancelProposalUseCase(repository: DIContainer.proposalRepository)
    )
  }

  // MARK: - Apply Detail (runner only)

  static func makeApplyDetailViewModel(
    proposalID: Int64,
    offerID: Int64
  ) -> ApplyDetailViewModel {
    ApplyDetailViewModel(
      proposalID: proposalID,
      offerID: offerID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOfferDetailUseCase: FetchOfferDetailUseCase(repository: DIContainer.offerRepository),
      completeDeliveryUseCase: CompleteDeliveryUseCase(repository: DIContainer.offerRepository),
      cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository)
    )
  }

  // MARK: - Applicant List

  static func makeApplicantListViewModel(proposalID: Int64) -> ApplicantListViewModel {
    ApplicantListViewModel(
      proposalID: proposalID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOffersUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository),
      acceptOfferUseCase: AcceptOfferUseCase(repository: DIContainer.offerRepository)
    )
  }

  // MARK: - Add Proposal (Fee 단계에서 실제 등록 API 호출)

  static func makeAddProposalViewModel() -> AddProposalViewModel {
    AddProposalViewModel(
      createProposalUseCase: CreateProposalUseCase(repository: DIContainer.proposalRepository)
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
