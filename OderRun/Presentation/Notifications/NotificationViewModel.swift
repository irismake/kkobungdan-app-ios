//
//  NotificationViewModel.swift
//  OderRun
//
//  Created by 김가희 on 4/22/26.
//

import Foundation

@Observable
final class NotificationViewModel {
  var notifications: [AppNotification] = []
  var isLoading: Bool = false
  var errorMessage: String?

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
    let vm = NotificationViewModel(
      fetchNotificationsUseCase: FetchNotificationsUseCase(repository: repo),
      repository: repo
    )
    vm.notifications = AppNotification.dummyList
    return vm
  }

  @MainActor
  func load() async {
    isLoading = true
    errorMessage = nil
    do {
      notifications = try await fetchNotificationsUseCase.execute()
    } catch {
      errorMessage = "알림을 불러오지 못했어요."
    }
    isLoading = false
  }

  @MainActor
  func markAsRead(id: String) async {
    do {
      try await repository.markAsRead(id: id)
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
