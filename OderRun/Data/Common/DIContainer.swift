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

  static func makeAuthRepository() -> AuthRepositoryProtocol {
    isDummy ? TestAuthRepositoryImpl() : AuthRepository(client: .shared, tokenStorage: .shared)
  }

  static func makeProposalRepository() -> ProposalRepositoryProtocol {
    isDummy ? TestProposalRepositoryImpl() : ProposalRepository(client: .shared)
  }

  static func makeOfferRepository() -> OfferRepositoryProtocol {
    isDummy ? TestOfferRepositoryImpl() : OfferRepository(client: .shared)
  }

  static func makeMissionRepository() -> MissionRepositoryProtocol {
    isDummy ? TestMissionRepositoryImpl() : MissionRepository(client: .shared)
  }

  static func makeUserRepository() -> UserRepositoryProtocol {
    isDummy ? TestUserRepositoryImpl() : UserRepository(client: .shared)
  }

  static func makeNotificationRepository() -> NotificationRepositoryProtocol {
    // TODO: API 스펙 확정 시 NotificationRepository 추가
    NotificationRepositoryImpl()
  }
}
