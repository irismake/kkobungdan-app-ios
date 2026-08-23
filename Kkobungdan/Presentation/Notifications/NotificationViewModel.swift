//
//  NotificationViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation
import OSLog
import UserNotifications

private let notificationLogger = Logger(
  subsystem: "com.kkobungdan.Kkobungdan",
  category: "Notification"
)

@Observable
final class NotificationViewModel: LoadableViewModel {
  var notifications: [AppNotification] = []
  var isLoading: Bool = false
  var isLoadingMore: Bool = false
  var errorMessage: String?
  /// 탭바 뱃지에 쓰는 전체 안읽음 개수. (목록은 페이지 단위라 stats API 로 별도 조회)
  var unreadCount: Int = 0

  private var page = 1
  private var hasNext = false

  private let fetchNotificationsUseCase: FetchNotificationsUseCase
  private let repository: NotificationRepositoryProtocol

  init(
    fetchNotificationsUseCase: FetchNotificationsUseCase,
    repository: NotificationRepositoryProtocol
  ) {
    self.fetchNotificationsUseCase = fetchNotificationsUseCase
    self.repository = repository
  }

  static func preview() -> NotificationViewModel {
    let repo = NotificationRepositoryImpl()
    let viewModel = NotificationViewModel(
      fetchNotificationsUseCase: FetchNotificationsUseCase(repository: repo),
      repository: repo
    )
    viewModel.notifications = AppNotification.dummyList
    return viewModel
  }

  @MainActor
  func load() async {
    await withLoading(fallback: "알림을 불러오지 못했어요.") {
      let firstPage = try await fetchNotificationsUseCase.execute()
      notifications = firstPage.notifications
      page = 1
      hasNext = firstPage.hasNext
    }
  }

  /// 목록과 뱃지를 한 번에 동기화한다.
  @MainActor
  func syncNotifications() async {
    await load()
    await refreshUnreadCount()
  }

  /// 서버 통계를 탭바와 앱 아이콘 뱃지에 함께 반영한다.
  @MainActor
  func refreshUnreadCount() async {
    do {
      let serverUnreadCount = try await repository.fetchStats().unread
      unreadCount = serverUnreadCount
      do {
        try await UNUserNotificationCenter.current().setBadgeCount(serverUnreadCount)
      } catch {
        notificationLogger.error("앱 아이콘 뱃지 갱신 실패: \(error)")
      }
    } catch {
      notificationLogger.error("안읽음 개수 갱신 실패: \(error)")
    }
  }

  /// 마지막 알림이 화면에 나타나면 다음 페이지를 이어 붙인다.
  /// 실패 시 조용히 멈추고, 마지막 셀이 다시 보일 때 재시도된다.
  @MainActor
  func loadMoreIfNeeded(currentItem: AppNotification) async {
    guard hasNext, !isLoadingMore, currentItem.id == notifications.last?.id else {
      return
    }
    isLoadingMore = true
    do {
      let nextPage = try await fetchNotificationsUseCase.execute(page: page + 1)
      page += 1
      notifications += nextPage.notifications
      hasNext = nextPage.hasNext
    } catch {
      if !error.isCancellation {
        errorMessage = error.userMessage(fallback: "알림을 더 불러오지 못했어요.")
      }
    }
    isLoadingMore = false
  }

  @MainActor
  func markAsRead(id: Int) async {
    do {
      let markedCount = try await repository.markAsRead(ids: [id])
      if let index = notifications.firstIndex(where: { $0.id == id }) {
        let existing = notifications[index]
        notifications[index] = AppNotification(
          id: existing.id,
          title: existing.title,
          body: existing.body,
          createdAt: existing.createdAt,
          isRead: true,
          deepLink: existing.deepLink
        )
      }
      // 통계 조회가 실패하더라도 서버가 실제 변경한 수만큼만 임시 반영한다.
      unreadCount = max(0, unreadCount - markedCount)
      await refreshUnreadCount()
    } catch {
      errorMessage = error.userMessage(fallback: "알림 상태를 변경하지 못했어요.")
    }
  }
}
