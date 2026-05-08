//
//  AppRoute.swift
//  OderRun
//
//  Created by 김가희 on 4/27/26.
//
//  HomeView 의 NavigationStack 에서 사용하는 push 라우팅 enum + ViewModel 팩토리.
//  더미 데이터 환경에서는 DIContainer 싱글턴 레포지토리를 그대로 사용해 in-memory 상태가 화면 간 공유된다.
//

import Foundation

enum AppRoute: Hashable {
  /// 홈 탭에서 다른 사람의 의뢰를 탭한 경우 (지원하기 화면)
  case proposalDetail(proposalID: Int64)
  /// 의뢰자 본인의 의뢰 상세
  case myProposalDetail(proposalID: Int64)
  /// 러너 본인의 지원 상세 (활동 탭에서 진입)
  case runnerApplyDetail(proposalID: Int64)
  /// 의뢰자가 지원자 한 명을 검토하는 상세
  case applicantOfferDetail(proposalID: Int64, offerID: Int64)
  /// 의뢰자가 자기 의뢰의 지원자 리스트를 보는 화면
  case applicantList(proposalID: Int64)
  /// 지원하기 성공 직후 안내 화면
  case applyComplete(proposalID: Int64)
  /// 새 의뢰 작성 — 1단계: 제목/내용
  case addProposalDraft
  /// 새 의뢰 작성 — 2단계: 날짜/시간
  case addProposalDateTime(draft: AddProposalDraft)
  /// 새 의뢰 작성 — 3단계: 웨이팅비 입력 + 등록
  case addProposalFee(draft: AddProposalDraft)
}

enum AppRouteFactory {
  // MARK: - Proposal Detail (non-mine)

  static func makeProposalDetailViewModel(proposalID: Int64) -> ProposalDetailViewModel {
    ProposalDetailViewModel(
      proposalID: proposalID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      createOfferUseCase: CreateOfferUseCase(repository: DIContainer.offerRepository),
      fetchMyOffersUseCase: FetchMyOffersUseCase(repository: DIContainer.offerRepository),
      userRepository: DIContainer.userRepository
    )
  }

  // MARK: - My Proposal Detail (orderer)

  static func makeMyProposalDetailViewModel(proposalID: Int64) -> MyProposalDetailViewModel {
    MyProposalDetailViewModel(
      proposalID: proposalID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOffersUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository),
      cancelProposalUseCase: CancelProposalUseCase(repository: DIContainer.proposalRepository),
      missionViewModel: makeMissionDetailViewModel(proposalID: proposalID, role: .orderer)
    )
  }

  // MARK: - Apply Detail (runner self / orderer accept mode)

  static func makeApplyDetailViewModel(
    proposalID: Int64,
    offerID: Int64? = nil,
    asRunner: Bool
  ) -> ApplyDetailViewModel {
    let missionVM: MissionDetailViewModel? = asRunner
      ? makeMissionDetailViewModel(proposalID: proposalID, role: .runner)
      : nil
    return ApplyDetailViewModel(
      proposalID: proposalID,
      offerID: offerID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOffersUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository),
      userRepository: DIContainer.userRepository,
      createMissionUseCase: CreateMissionUseCase(repository: DIContainer.missionRepository),
      missionViewModel: missionVM
    )
  }

  // MARK: - Applicant List

  static func makeApplicantListViewModel(proposalID: Int64) -> ApplicantListViewModel {
    ApplicantListViewModel(
      proposalID: proposalID,
      fetchDetailUseCase: FetchProposalDetailUseCase(repository: DIContainer.proposalRepository),
      fetchOffersUseCase: FetchOffersByProposalUseCase(repository: DIContainer.offerRepository),
      userRepository: DIContainer.userRepository, createMissionUseCase: <#CreateMissionUseCase#>
    )
  }

  // MARK: - Add Proposal (Fee 단계에서 실제 등록 API 호출)

  static func makeAddProposalViewModel() -> AddProposalViewModel {
    AddProposalViewModel(
      createProposalUseCase: CreateProposalUseCase(repository: DIContainer.proposalRepository)
    )
  }

  // MARK: - Mission Detail

  static func makeMissionDetailViewModel(
    proposalID: Int64,
    role: MissionRole
  ) -> MissionDetailViewModel {
    MissionDetailViewModel(
      proposalID: proposalID,
      role: role,
      fetchMyMissionsUseCase: FetchMyMissionsUseCase(repository: DIContainer.missionRepository),
      updateMissionActionUseCase: UpdateMissionActionUseCase(repository: DIContainer.missionRepository)
    )
  }
}
