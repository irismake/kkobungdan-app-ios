//
//  NotificationViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class NotificationViewModel: LoadableViewModel {
  var notifications: [AppNotification] = []
  var isLoading: Bool = false
  var isLoadingMore: Bool = false
  var errorMessage: String?

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

  @MainActor
  func load() async {
    await withLoading(fallback: "알림을 불러오지 못했어요.") {
      let firstPage = try await fetchNotificationsUseCase.execute()
      notifications = firstPage.notifications
      page = 1
      hasNext = firstPage.hasNext
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
      _ = try await repository.markAsRead(ids: [id])
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
    } catch {
      errorMessage = error.userMessage(fallback: "알림 상태를 변경하지 못했어요.")
    }
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension NotificationViewModel {
  static func preview() -> NotificationViewModel {
    let repo = NotificationRepositoryImpl()
    let viewModel = NotificationViewModel(
      fetchNotificationsUseCase: FetchNotificationsUseCase(repository: repo),
      repository: repo
    )
    viewModel.notifications = AppNotification.dummyList
    return viewModel
  }
}
