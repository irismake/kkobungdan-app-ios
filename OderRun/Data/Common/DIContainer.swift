//
//  DIContainer.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

enum DIContainer {
  /// ← true: 더미 데이터 / false: 실 API
  static let isDummy: Bool = true

  /// 앱 전체에서 동일한 인스턴스를 공유 — 인메모리 상태(추가/수정/삭제)가 모든 화면에 반영됨
  static let authRepository: AuthRepositoryProtocol =
    isDummy ? TestAuthRepositoryImpl() : AuthRepository(client: .shared, tokenStorage: .shared)

  static let proposalRepository: ProposalRepositoryProtocol =
    isDummy ? TestProposalRepositoryImpl() : ProposalRepository(client: .shared)

  static let offerRepository: OfferRepositoryProtocol =
    isDummy ? TestOfferRepositoryImpl() : OfferRepository(client: .shared)

  static let missionRepository: MissionRepositoryProtocol =
    isDummy ? TestMissionRepositoryImpl() : MissionRepository(client: .shared)

  static let activityRepository: ActivityRepositoryProtocol =
    isDummy ? TestActivityRepositoryImpl() : ActivityRepository(client: .shared)

  static let userRepository: UserRepositoryProtocol =
    isDummy ? TestUserRepositoryImpl() : UserRepository(client: .shared)

  static let notificationRepository: NotificationRepositoryProtocol =
    NotificationRepositoryImpl() // TODO: API 스펙 확정 시 교체
}
