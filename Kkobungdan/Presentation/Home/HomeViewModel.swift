//
//  HomeViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog
import UserNotifications

private let homeLogger = Logger(subsystem: "com.kkobungdan.Kkobungdan", category: "Home")

@Observable
final class HomeViewModel: LoadableViewModel {
  var proposals: [Proposal] = []
  var isLoading: Bool = false
  var errorMessage: String?
  /// 헤더 알림 버튼 뱃지에 쓰는 전체 안읽음 개수. (알림 목록은 페이지 단위라 stats API 로 별도 조회)
  var unreadNotificationCount: Int = 0

  private let fetchProposalsUseCase: FetchProposalsUseCase
  private let fetchNotificationStatsUseCase: FetchNotificationStatsUseCase

  init(
    fetchProposalsUseCase: FetchProposalsUseCase,
    fetchNotificationStatsUseCase: FetchNotificationStatsUseCase
  ) {
    self.fetchProposalsUseCase = fetchProposalsUseCase
    self.fetchNotificationStatsUseCase = fetchNotificationStatsUseCase
  }

  @MainActor
  func load() async {
    await withLoading(fallback: "요청 목록을 불러오지 못했어요.") {
      // 홈 피드는 아직 지원 가능한 공개 요청(등록 완료 / 새 지원 도착)만 노출한다.
      proposals = try await fetchProposalsUseCase.execute(status: [.posted, .offered])
    }
    await refreshUnreadNotificationCount()
  }

  /// 서버 통계를 헤더 알림 뱃지와 앱 아이콘 뱃지에 함께 반영한다. 실패해도 화면 에러로 노출하지 않는다.
  @MainActor
  func refreshUnreadNotificationCount() async {
    do {
      let unread = try await fetchNotificationStatsUseCase.execute().unread
      unreadNotificationCount = unread
      do {
        try await UNUserNotificationCenter.current().setBadgeCount(unread)
      } catch {
        homeLogger.error("앱 아이콘 뱃지 갱신 실패: \(error)")
      }
    } catch {
      homeLogger.error("안읽음 알림 개수 갱신 실패: \(error)")
    }
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension HomeViewModel {
  static func preview() -> HomeViewModel {
    let viewModel = HomeViewModel(
      fetchProposalsUseCase: FetchProposalsUseCase(repository: DIContainer.proposalRepository),
      fetchNotificationStatsUseCase: FetchNotificationStatsUseCase(repository: DIContainer.notificationRepository)
    )
    viewModel.proposals = Proposal.dummyList
    viewModel.unreadNotificationCount = 3
    return viewModel
  }
}
