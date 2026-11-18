//
//  ChatRoomViewModel.swift
//  Kkobungdan
//
//  채팅 상세 VM. 대화방 상태·내 입장(행님/꼬붕)으로 하단 액션 바와 입력 가능 여부를 정한다.
//  지원 취소·매칭·임무 수행 완료는 상세 화면과 같은 유스케이스를 쓰고, 안내 문구는 서버 시스템 메시지로 받는다.
//

import Foundation

/// 채팅 상세 하단 액션 바(입력창 위 보라색 바).
enum ChatRoomBottomAction: Equatable {
  /// 꼬붕 · 대기중
  case cancelOffer
  /// 행님 · 대기중
  case acceptOffer
  /// 진행중 · 내가 아직 임무 수행 완료를 누르지 않음
  case completeMission
  /// 완료
  case viewMission

  var message: String {
    switch self {
    case .cancelOffer: return "행님의 매칭 확정을 기다리고 있어요"
    case .acceptOffer: return "채팅으로 조건을 확인하셨나요?"
    case .completeMission: return "임무 수행을 완료하겠습니까?"
    case .viewMission: return "완료 · 상태와 처리 내역"
    }
  }

  var buttonTitle: String {
    switch self {
    case .cancelOffer: return "지원 취소"
    case .acceptOffer: return "이 꼬붕과 매칭"
    case .completeMission: return "임무 수행 완료"
    case .viewMission: return "임무 보기"
    }
  }
}

/// 메시지 목록의 한 줄 — 날짜 구분선 또는 메시지.
enum ChatRoomItem: Identifiable, Equatable {
  case date(Date)
  case message(ChatMessage)

  var id: String {
    switch self {
    case let .date(date): return "date-\(date.timeIntervalSince1970)"
    case let .message(message): return "message-\(message.id)"
    }
  }
}

@Observable
final class ChatRoomViewModel: LoadableViewModel {
  let roomID: Int64

  var room: ChatRoomDetail?
  var messages: [ChatMessage] = []
  var draft: String = ""
  var isLoading: Bool = false
  var isSending: Bool = false
  var isPerformingAction: Bool = false
  var errorMessage: String?

  private let fetchChatRoomDetailUseCase: FetchChatRoomDetailUseCase
  private let fetchChatMessagesUseCase: FetchChatMessagesUseCase
  private let sendChatMessageUseCase: SendChatMessageUseCase
  private let cancelOfferUseCase: CancelOfferUseCase
  private let acceptOfferUseCase: AcceptOfferUseCase
  private let completeDeliveryUseCase: CompleteDeliveryUseCase
  private let confirmReceivedUseCase: ConfirmReceivedUseCase

  init(
    roomID: Int64,
    fetchChatRoomDetailUseCase: FetchChatRoomDetailUseCase,
    fetchChatMessagesUseCase: FetchChatMessagesUseCase,
    sendChatMessageUseCase: SendChatMessageUseCase,
    cancelOfferUseCase: CancelOfferUseCase,
    acceptOfferUseCase: AcceptOfferUseCase,
    completeDeliveryUseCase: CompleteDeliveryUseCase,
    confirmReceivedUseCase: ConfirmReceivedUseCase
  ) {
    self.roomID = roomID
    self.fetchChatRoomDetailUseCase = fetchChatRoomDetailUseCase
    self.fetchChatMessagesUseCase = fetchChatMessagesUseCase
    self.sendChatMessageUseCase = sendChatMessageUseCase
    self.cancelOfferUseCase = cancelOfferUseCase
    self.acceptOfferUseCase = acceptOfferUseCase
    self.completeDeliveryUseCase = completeDeliveryUseCase
    self.confirmReceivedUseCase = confirmReceivedUseCase
  }

  // MARK: - Derived

  var bottomAction: ChatRoomBottomAction? {
    guard let room else {
      return nil
    }
    switch room.status {
    case .waiting:
      return room.myRole == .runner ? .cancelOffer : .acceptOffer
    case .inProgress:
      // 양측이 모두 눌러야 완료 — 이미 누른 쪽은 상대를 기다리는 안내(시스템 메시지)만 본다.
      return room.didICompleteMission ? nil : .completeMission
    case .completed:
      return .viewMission
    case .cancelled, .disputed:
      return nil
    }
  }

  var canSendMessage: Bool {
    room?.canSendMessage ?? false
  }

  var canSubmitDraft: Bool {
    canSendMessage && !isSending && !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
  }

  /// 메시지 사이에 날짜가 바뀌면 날짜 구분선을 끼워 넣는다.
  var items: [ChatRoomItem] {
    var result: [ChatRoomItem] = []
    var previous: Date?
    for message in messages {
      if previous.map({ !DisplayFormatter.isSameChatDay($0, message.sentAt) }) ?? true {
        result.append(.date(message.sentAt))
      }
      result.append(.message(message))
      previous = message.sentAt
    }
    return result
  }

  // MARK: - Load

  @MainActor
  func load() async {
    await withLoading(fallback: "채팅을 불러오지 못했어요.") {
      async let roomTask = fetchChatRoomDetailUseCase.execute(roomID: roomID)
      async let messagesTask = fetchChatMessagesUseCase.execute(roomID: roomID)
      let (room, messages) = try await (roomTask, messagesTask)
      self.room = room
      self.messages = messages
    }
  }

  // MARK: - Send

  @MainActor
  func send() async {
    let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
    guard canSubmitDraft else {
      return
    }
    isSending = true
    errorMessage = nil
    do {
      let message = try await sendChatMessageUseCase.execute(roomID: roomID, text: text)
      messages.append(message)
      draft = ""
    } catch {
      if !error.isCancellation {
        errorMessage = error.userMessage(fallback: "메시지를 보내지 못했어요.")
      }
    }
    isSending = false
  }

  // MARK: - Actions

  /// 꼬붕이 대기중 지원을 취소한다. 대화방은 남고 '지원 취소' 안내와 함께 종료된다.
  @MainActor
  func cancelOffer() async {
    await performAction(fallback: "지원을 취소하지 못했어요.") {
      try await cancelOfferUseCase.execute(offerID: roomID)
    }
  }

  /// 행님이 이 대화방의 꼬붕과 매칭한다. `POST /v1/offer/{offerId}/accept`
  @MainActor
  func acceptOffer() async {
    await performAction(fallback: "매칭하지 못했어요. 잠시 후 다시 시도해주세요.") {
      _ = try await acceptOfferUseCase.execute(offerID: roomID)
    }
  }

  /// 임무 수행 완료. 꼬붕은 배달 완료, 행님은 수령 확인 — 양측 모두 누르면 미션 완료.
  @MainActor
  func completeMission() async {
    guard let room else {
      return
    }
    await performAction(fallback: "임무 완료 처리에 실패했어요. 잠시 후 다시 시도해주세요.") {
      switch room.myRole {
      case .runner:
        _ = try await completeDeliveryUseCase.execute(offerID: roomID)
      case .orderer:
        _ = try await confirmReceivedUseCase.execute(proposalID: room.proposalID)
      }
    }
  }

  /// 상태를 바꾸는 행동 후, 서버가 남긴 안내 메시지와 새 상태를 다시 받아온다.
  @MainActor
  private func performAction(fallback: String, operation: () async throws -> Void) async {
    guard !isPerformingAction else {
      return
    }
    isPerformingAction = true
    errorMessage = nil
    do {
      try await operation()
      NotificationCenter.default.post(name: .proposalListNeedsRefresh, object: nil)
      await load()
    } catch {
      if !error.isCancellation {
        errorMessage = error.userMessage(fallback: fallback)
      }
    }
    isPerformingAction = false
  }
}

// MARK: - Preview

/// SwiftUI `#Preview` 전용 — 더미 데이터로 채운 VM 을 만든다. 운영 코드에서 호출하지 않는다.
extension ChatRoomViewModel {
  static func preview(
    myRole: ChatRole = .runner,
    status: ChatRoomStatus = .waiting,
    didICompleteMission: Bool = false
  ) -> ChatRoomViewModel {
    let viewModel = ChatRoomViewModel(
      roomID: 50,
      fetchChatRoomDetailUseCase: FetchChatRoomDetailUseCase(repository: DIContainer.chatRepository),
      fetchChatMessagesUseCase: FetchChatMessagesUseCase(repository: DIContainer.chatRepository),
      sendChatMessageUseCase: SendChatMessageUseCase(repository: DIContainer.chatRepository),
      cancelOfferUseCase: CancelOfferUseCase(repository: DIContainer.offerRepository),
      acceptOfferUseCase: AcceptOfferUseCase(repository: DIContainer.offerRepository),
      completeDeliveryUseCase: CompleteDeliveryUseCase(repository: DIContainer.offerRepository),
      confirmReceivedUseCase: ConfirmReceivedUseCase(repository: DIContainer.proposalRepository)
    )
    let now = Date()
    viewModel.room = ChatRoomDetail(
      id: 50,
      proposalID: 1,
      proposalTitle: "성수 베이커리 소금빵 웨이팅",
      errandFee: 10000,
      deadline: now.addingTimeInterval(86400),
      counterpartName: myRole == .runner ? "성수동 행님" : "카야잼",
      myRole: myRole,
      status: status,
      didICompleteMission: didICompleteMission
    )
    viewModel.messages = [
      ChatMessage(id: 1, sender: .system, text: "지원으로 채팅이 시작되었어요.", sentAt: now.addingTimeInterval(-600)),
      ChatMessage(id: 2, sender: .counterpart, text: "안녕하세요! 요청하신 시간에 도착할 수 있어요. 만날 장소를 알려주세요.", sentAt: now.addingTimeInterval(-300)),
      ChatMessage(id: 3, sender: .me, text: "안녕하세요! 오후 3시에 도착할 수 있어요.", sentAt: now.addingTimeInterval(-120))
    ]
    return viewModel
  }
}
