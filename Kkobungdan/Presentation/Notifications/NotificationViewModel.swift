//
//  NotificationViewModel.swift
//  Kkobungdan
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class NotificationViewModel {
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
    isLoading = true
    errorMessage = nil
    do {
      let firstPage = try await fetchNotificationsUseCase.execute()
      notifications = firstPage.notifications
      page = 1
      hasNext = firstPage.hasNext
    } catch {
      errorMessage = "알림을 불러오지 못했어요."
    }
    isLoading = false
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
    } catch {}
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
          isRead: true
        )
      }
    } catch {
      errorMessage = "알림 상태를 변경하지 못했어요."
    }
  }
}
