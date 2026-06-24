//
//  DIContainer.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum DIContainer {
  /// ← true: 더미 데이터 / false: 실 API
  static let isDummy: Bool = false

  /// 더미 환경에서 proposal / offer 를 공유하는 단일 인메모리 백엔드.
  /// 실 API 모드에서는 사용되지 않는다.
  private static let dummyStore = DummyBackendStore()

  /// 앱 전체에서 동일한 인스턴스를 공유 — 인메모리 상태(추가/수정/삭제)가 모든 화면에 반영됨
  static let authRepository: AuthRepositoryProtocol =
    isDummy ? TestAuthRepositoryImpl() : AuthRepository(client: .shared, tokenStorage: .shared)

  static let oauthRepository: OauthRepositoryProtocol =
    isDummy ? TestOauthRepositoryImpl() : OauthRepository(client: .shared, tokenStorage: .shared)

  static let proposalRepository: ProposalRepositoryProtocol =
    isDummy ? TestProposalRepositoryImpl(store: dummyStore) : ProposalRepository(client: .shared)

  static let offerRepository: OfferRepositoryProtocol =
    isDummy ? TestOfferRepositoryImpl(store: dummyStore) : OfferRepository(client: .shared)

  static let activityRepository: ActivityRepositoryProtocol =
    isDummy ? TestActivityRepositoryImpl(store: dummyStore) : ActivityRepository(client: .shared)

  static let userRepository: UserRepositoryProtocol =
    isDummy ? TestUserRepositoryImpl() : UserRepository(client: .shared)

  static let termsRepository: TermsRepositoryProtocol =
    isDummy ? TestTermsRepositoryImpl() : TermsRepository(client: .shared)

  static let settlementRepository: SettlementRepositoryProtocol =
    isDummy ? TestSettlementRepositoryImpl() : SettlementRepository(client: .shared)

  static let notificationRepository: NotificationRepositoryProtocol =
    isDummy ? NotificationRepositoryImpl() : NotificationRepository(client: .shared)

  static let disputeSurveyRepository: DisputeSurveyRepositoryProtocol =
    isDummy ? TestDisputeSurveyRepositoryImpl() : DisputeSurveyRepository(client: .shared)

  static let reportRepository: ReportRepositoryProtocol =
    isDummy ? TestReportRepositoryImpl() : ReportRepository(client: .shared)
}
