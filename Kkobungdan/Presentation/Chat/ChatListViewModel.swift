//
//  ChatListViewModel.swift
//  Kkobungdan
//
//  채팅 탭 루트 VM. 탭바 채팅 뱃지(안읽음 수)도 이 VM 이 제공한다.
//

import Foundation

enum ChatListFilter: CaseIterable {
  case all
  case unread
  case inProgress

  var title: String {
    switch self {
    case .all: return "전체"
    case .unread: return "안 읽음"
    case .inProgress: return "진행중"
    }
  }
}

@Observable
final class ChatListViewModel: LoadableViewModel {
  var rooms: [ChatRoom] = []
  var filter: ChatListFilter = .all
  var isLoading: Bool = false
  var errorMessage: String?

  private let fetchChatRoomsUseCase: FetchChatRoomsUseCase
  private let markAllChatRoomsReadUseCase: MarkAllChatRoomsReadUseCase

  init(
    fetchChatRoomsUseCase: FetchChatRoomsUseCase,
    markAllChatRoomsReadUseCase: MarkAllChatRoomsReadUseCase
  ) {
    self.fetchChatRoomsUseCase = fetchChatRoomsUseCase
    self.markAllChatRoomsReadUseCase = markAllChatRoomsReadUseCase
  }

  var filteredRooms: [ChatRoom] {
    switch filter {
    case .all: return rooms
    case .unread: return rooms.filter { $0.unreadCount > 0 }
    case .inProgress:
      // 상태 배지가 '진행중'인 대화 (요청 카드와 같은 기준)
      return rooms.filter {
        ActivityStatusBadge.badges(chatRoom: $0).contains { $0.text == ActivityStatusBadge.inProgressBadge.text }
      }
    }
  }

  /// 전체 안읽음 메시지 수. 헤더 개수·탭바 뱃지에 쓴다.
  var unreadCount: Int {
    rooms.reduce(0) { $0 + $1.unreadCount }
  }

  @MainActor
  func load() async {
    await withLoading(fallback: "채팅 목록을 불러오지 못했어요.") {
      rooms = try await fetchChatRoomsUseCase.execute()
    }
  }

  @MainActor
  func markAllAsRead() async {
    do {
      try await markAllChatRoomsReadUseCase.execute()
      rooms = try await fetchChatRoomsUseCase.execute()
    } catch {
      guard !error.isCancellation else {
        return
      }
      errorMessage = error.userMessage(fallback: "읽음 처리하지 못했어요.")
    }
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension ChatListViewModel {
  static func preview() -> ChatListViewModel {
    let viewModel = ChatListViewModel(
      fetchChatRoomsUseCase: FetchChatRoomsUseCase(repository: DIContainer.chatRepository),
      markAllChatRoomsReadUseCase: MarkAllChatRoomsReadUseCase(repository: DIContainer.chatRepository)
    )
    viewModel.rooms = ChatRoom.dummyList
    return viewModel
  }
}
