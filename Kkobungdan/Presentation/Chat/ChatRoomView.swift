//
//  ChatRoomView.swift
//  Kkobungdan
//
//  채팅 상세. 상단 요청 요약 → 메시지 → 하단 액션 바 → 입력창(종료 시 종료 안내).
//

import SwiftUI

struct ChatRoomView: View {
  @State private var viewModel: ChatRoomViewModel
  @State private var isCancelConfirmPresented: Bool = false
  @State private var isAcceptModalPresented: Bool = false
  @State private var isCompleteModalPresented: Bool = false
  @FocusState private var isInputFocused: Bool
  var onBack: () -> Void = {}
  /// 요청 요약 바·'임무 보기' → 내 입장의 상세 화면(행님: 내 요청 상세, 꼬붕: 내 지원 상세).
  var onOpenMission: (ChatRoomDetail) -> Void = { _ in }

  init(
    viewModel: ChatRoomViewModel,
    onBack: @escaping () -> Void = {},
    onOpenMission: @escaping (ChatRoomDetail) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onBack = onBack
    self.onOpenMission = onOpenMission
  }

  var body: some View {
    ZStack {
      contentView

      if isAcceptModalPresented, let room = viewModel.room {
        RunnerSelectModal(
          runnerName: room.counterpartName,
          onCancel: { isAcceptModalPresented = false },
          onConfirm: {
            Task {
              await viewModel.acceptOffer()
              isAcceptModalPresented = false
            }
          }
        )
      }

      if isCompleteModalPresented, let room = viewModel.room {
        MissionCompleteModal(
          title: room.myRole == .runner ? "임무 완료 처리하시겠습니까?" : "진행 완료 처리하시겠습니까?",
          isRunner: room.myRole == .runner,
          infoTitle: "취소 안내",
          infoContent: "완료 처리 후 취소가 불가능하며 문제 발생 시 고객센터 이메일로 문의 부탁드립니다.",
          onCancel: { isCompleteModalPresented = false },
          onConfirm: {
            Task {
              await viewModel.completeMission()
              isCompleteModalPresented = false
            }
          }
        )
      }
    }
    .errorToast($viewModel.errorMessage)
  }

  private var contentView: some View {
    VStack(spacing: 0) {
      header

      if let room = viewModel.room {
        summaryBar(room)
      }

      messageList

      if let action = viewModel.bottomAction {
        actionBar(action)
      }

      if viewModel.room != nil {
        if viewModel.canSendMessage {
          inputBar
        } else {
          closedFooter
        }
      }
    }
    .background(Color.gray000)
    .task {
      await viewModel.load()
    }
    .alert("지원을 취소할까요?", isPresented: $isCancelConfirmPresented) {
      Button("취소", role: .cancel) {}
      Button("지원 취소", role: .destructive) {
        Task { await viewModel.cancelOffer() }
      }
    } message: {
      Text("지원을 취소하면 되돌릴 수 없어요.")
    }
  }

  // MARK: - Header

  private var header: some View {
    HStack(spacing: 0) {
      Button(action: onBack) {
        Image("icon_previous")
          .resizable()
          .frame(width: 24, height: 24)
          .padding(.top, 8)
          .frame(width: 44, height: 44, alignment: .top)
      }
      .buttonStyle(.plain)

      Text(viewModel.room?.counterpartName ?? "")
        .textStyle(.heading3)
        .foregroundColor(.gray900)
        .lineLimit(1)
        .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        // TODO: 채팅 관리 메뉴 항목 확정 후 연결
      } label: {
        Text("···")
          .textStyle(.symbol1)
          .foregroundColor(.gray900)
          .padding(.horizontal, 6)
          .frame(width: 44, height: 44)
      }
      .buttonStyle(.plain)
    }
    .padding(.leading, 8)
    .padding(.trailing, 16)
    .frame(height: 52)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  private func summaryBar(_ room: ChatRoomDetail) -> some View {
    Button {
      onOpenMission(room)
    } label: {
      HStack(spacing: 10) {
        VStack(alignment: .leading, spacing: 0) {
          Text(room.proposalTitle)
            .textStyle(.title7)
            .foregroundColor(.gray900)
            .lineLimit(1)

          Text("\(DisplayFormatter.feeString(room.errandFee)) · \(DisplayFormatter.dateString(room.deadline))")
            .textStyle(.caption7)
            .foregroundColor(.gray500)
            .lineLimit(1)
            .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)

        Badge(
          text: room.status.badge.text,
          textColor: room.status.badge.textColor,
          bgColor: room.status.badge.bgColor,
          iconName: room.status.badge.iconName
        )

        Text("›")
          .textStyle(.title4)
          .foregroundColor(.gray900)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 12)
      .frame(minHeight: 66)
      .background(Color.white)
      .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  // MARK: - Messages

  private var messageList: some View {
    ScrollViewReader { proxy in
      ScrollView {
        LazyVStack(spacing: 0) {
          if viewModel.room == nil, viewModel.isLoading {
            ProgressView()
              .padding(.top, 40)
          }

          ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
            switch item {
            case let .date(date):
              Text(DisplayFormatter.dateString(date))
                .textStyle(.caption8)
                .foregroundColor(.gray400)
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            case let .message(message):
              messageRow(message)
                .padding(.top, topSpacing(for: message, at: index))
                .id(item.id)
            }
          }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
      }
      .scrollDismissesKeyboard(.interactively)
      .frame(maxHeight: .infinity)
      // 대화는 위에서부터 쌓인다. 넘치면 처음 진입 시 마지막 메시지로, 새 메시지는 애니메이션으로 내린다.
      .onChange(of: viewModel.messages.last?.id) { oldID, lastID in
        guard let lastID else {
          return
        }
        if oldID == nil {
          proxy.scrollTo("message-\(lastID)", anchor: .bottom)
        } else {
          withAnimation {
            proxy.scrollTo("message-\(lastID)", anchor: .bottom)
          }
        }
      }
    }
  }

  @ViewBuilder
  private func messageRow(_ message: ChatMessage) -> some View {
    switch message.sender {
    case .system:
      Text(message.text)
        .textStyle(.caption7)
        .foregroundColor(.gray500)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.gray100)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 10)

    case .me:
      HStack(alignment: .bottom, spacing: 6) {
        Spacer(minLength: 0)

        Text(DisplayFormatter.messageTimeString(message.sentAt))
          .textStyle(.caption9)
          .foregroundColor(.gray400)

        bubble(message.text, isMine: true)
      }

    case .counterpart:
      VStack(alignment: .leading, spacing: 5) {
        Text(viewModel.room?.counterpartName ?? "")
          .textStyle(.caption2)
          .foregroundColor(.gray600)

        HStack(alignment: .bottom, spacing: 6) {
          bubble(message.text, isMine: false)

          Text(DisplayFormatter.messageTimeString(message.sentAt))
            .textStyle(.caption9)
            .foregroundColor(.gray400)

          Spacer(minLength: 0)
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
  }

  /// 말풍선. 보낸 쪽 위 모서리만 2, 나머지 14. 내 것은 보라 배경, 상대 것은 흰 배경 + 테두리.
  private func bubble(_ text: String, isMine: Bool) -> some View {
    let shape = UnevenRoundedRectangle(
      topLeadingRadius: isMine ? 14 : 2,
      bottomLeadingRadius: 14,
      bottomTrailingRadius: 14,
      topTrailingRadius: isMine ? 2 : 14
    )
    return CappedWidthLayout(maxWidth: Self.bubbleTextMaxWidth) {
      Text(text)
        .textStyle(.body6)
        .foregroundColor(isMine ? .white : .gray900)
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 11)
    .background(isMine ? Color.indigo500 : Color.white, in: shape)
    .overlay(shape.stroke(isMine ? Color.indigo500 : Color.gray100, lineWidth: 1))
  }

  /// 말풍선 텍스트 최대 너비 (Figma 252).
  private static let bubbleTextMaxWidth: CGFloat = 252

  /// 메시지 위 간격. 대화 말풍선 바로 다음의 시스템 안내만 16, 나머지는 20.
  private func topSpacing(for message: ChatMessage, at index: Int) -> CGFloat {
    guard message.sender == .system,
          index > 0,
          case let .message(previous) = viewModel.items[index - 1],
          previous.sender != .system
    else {
      return 20
    }
    return 16
  }

  // MARK: - Bottom

  private func actionBar(_ action: ChatRoomBottomAction) -> some View {
    HStack(spacing: 8) {
      Text(action.message)
        .textStyle(.caption2)
        .foregroundColor(.gray600)
        .frame(maxWidth: .infinity, alignment: .leading)

      Button {
        handle(action)
      } label: {
        Text(action.buttonTitle)
          .textStyle(.button3)
          .foregroundColor(.indigo500)
          .padding(.horizontal, 10)
          .frame(height: 32)
          .background(Color.white)
          .clipShape(RoundedRectangle(cornerRadius: 8))
      }
      .buttonStyle(.plain)
      .disabled(viewModel.isPerformingAction)
    }
    .padding(.horizontal, 16)
    .frame(height: 53)
    .background(Color.indigo000)
    .overlay(alignment: .top) {
      Rectangle().fill(Color.indigo100).frame(height: 1)
    }
  }

  private func handle(_ action: ChatRoomBottomAction) {
    switch action {
    case .cancelOffer:
      isCancelConfirmPresented = true
    case .acceptOffer:
      isAcceptModalPresented = true
    case .completeMission:
      isCompleteModalPresented = true
    case .viewMission:
      if let room = viewModel.room {
        onOpenMission(room)
      }
    }
  }

  private var inputBar: some View {
    HStack(alignment: .bottom, spacing: 8) {
      TextField(
        "",
        text: $viewModel.draft,
        prompt: Text("메시지를 입력하세요").foregroundColor(.gray500),
        axis: .vertical
      )
      .textStyle(.body3)
      .kerning(0)
      .foregroundColor(.gray900)
      .lineLimit(1 ... 4)
      .focused($isInputFocused)
      .padding(.horizontal, 12)
      .padding(.vertical, 10)
      .frame(minHeight: 64, alignment: .topLeading)
      .background(Color.gray000)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.gray200, lineWidth: 1)
      )

      Button {
        Task { await viewModel.send() }
      } label: {
        Text("전송")
          .textStyle(.title2)
          .kerning(0)
          .foregroundColor(viewModel.canSubmitDraft ? .white : .gray400)
          .padding(.horizontal, 12)
          .frame(height: 44)
          .background(viewModel.canSubmitDraft ? Color.indigo500 : Color.gray200)
          .clipShape(RoundedRectangle(cornerRadius: 10))
      }
      .buttonStyle(.plain)
      .disabled(!viewModel.canSubmitDraft)
    }
    .padding(.horizontal, 16)
    .padding(.top, 12)
    .padding(.bottom, 12)
    .background(Color.white)
    .overlay(alignment: .top) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }

  private var closedFooter: some View {
    Text("채팅이 종료되었습니다. 이전 메시지는 계속 볼 수 있어요.")
      .textStyle(.caption7)
      .foregroundColor(.gray500)
      .multilineTextAlignment(.center)
      .frame(maxWidth: .infinity)
      // Figma 아래 38 = 홈 인디케이터 영역(34) + 4 — 흰 배경은 하단 안전 영역까지 채운다.
      .padding(.top, 18)
      .padding(.bottom, 4)
      .background(Color.white.ignoresSafeArea(edges: .bottom))
      .overlay(alignment: .top) {
        Rectangle().fill(Color.gray200).frame(height: 1)
      }
  }
}

/// 자식에게 최대 너비까지만 제안한다. 짧은 글은 자기 너비, 긴 글은 `maxWidth` 에서 줄바꿈.
/// (`.frame(maxWidth:)` 는 짧은 글도 최대 너비로 늘려서 쓰지 않는다)
private struct CappedWidthLayout: SwiftUI.Layout {
  let maxWidth: CGFloat

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
    guard let subview = subviews.first else {
      return .zero
    }
    return subview.sizeThatFits(cappedProposal(proposal))
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
    subviews.first?.place(at: bounds.origin, proposal: cappedProposal(proposal))
  }

  private func cappedProposal(_ proposal: ProposedViewSize) -> ProposedViewSize {
    ProposedViewSize(width: min(proposal.width ?? maxWidth, maxWidth), height: proposal.height)
  }
}

#Preview("꼬붕 · 대기중") {
  ChatRoomView(viewModel: .preview(myRole: .runner, status: .waiting))
}

#Preview("행님 · 대기중") {
  ChatRoomView(viewModel: .preview(myRole: .orderer, status: .waiting))
}

#Preview("완료") {
  ChatRoomView(viewModel: .preview(myRole: .orderer, status: .completed))
}
