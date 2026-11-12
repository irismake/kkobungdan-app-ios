import SwiftUI

/// 메인 탭의 '채팅' 세그먼트. 대화방 목록 + 필터(전체/안 읽음/진행중).
struct ChatListView: View {
  @State private var viewModel: ChatListViewModel
  var onSelectRoom: (ChatRoom) -> Void = { _ in }

  init(
    viewModel: ChatListViewModel,
    onSelectRoom: @escaping (ChatRoom) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onSelectRoom = onSelectRoom
  }

  var body: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "채팅", count: viewModel.unreadCount) {
        Button {
          Task { await viewModel.markAllAsRead() }
        } label: {
          Text("모두 읽음")
            .textStyle(.caption5)
            .foregroundColor(.gray500)
            .padding(4)
        }
        .buttonStyle(.plain)
      }

      FilterChips(items: ChatListFilter.allCases, selection: $viewModel.filter) { $0.title }
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white)
        .overlay(alignment: .bottom) {
          Rectangle().fill(Color.gray200).frame(height: 1)
        }

      ScrollView {
        LazyVStack(spacing: 0) {
          if viewModel.isLoading, viewModel.rooms.isEmpty {
            ProgressView()
              .padding(.top, 40)
              .frame(maxWidth: .infinity)
          } else if viewModel.filteredRooms.isEmpty {
            Text("아직 채팅이 없어요.")
              .textStyle(.body3)
              .foregroundColor(Color.gray500)
              .padding(.top, 40)
              .frame(maxWidth: .infinity)
          } else {
            ForEach(viewModel.filteredRooms) { room in
              Button {
                onSelectRoom(room)
              } label: {
                ChatRoomRow(room: room)
              }
              .buttonStyle(.plain)
            }
          }
        }
      }
      .background(Color.gray000)
      .refreshable {
        await viewModel.load()
      }
    }
    .background(Color.gray000)
    .errorToast($viewModel.errorMessage)
  }
}

/// 채팅 목록의 대화방 한 줄.
private struct ChatRoomRow: View {
  let room: ChatRoom

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(spacing: 6) {
        Text(room.counterpartName)
          .textStyle(.title6)
          .foregroundColor(.gray900)

        Spacer(minLength: 0)

        Text(DisplayFormatter.chatTimeString(room.lastMessageAt))
          .textStyle(.caption8)
          .foregroundColor(.gray400)
      }

      Text(room.proposalTitle)
        .textStyle(.caption7)
        .foregroundColor(.gray500)
        .lineLimit(1)
        .padding(.top, 3)

      HStack(spacing: 8) {
        Text(room.lastMessage)
          .textStyle(.body3)
          .kerning(0)
          .foregroundColor(.gray700)
          .lineLimit(1)
          .truncationMode(.tail)
          .frame(maxWidth: .infinity, alignment: .leading)

        if room.unreadCount > 0 {
          CountBadge(count: room.unreadCount)
        }
      }
      .padding(.top, 5)

      // 서버가 내려준 대화방 상태를 요청 카드(ProposalCard)와 같은 배지로 표시
      Badge(
        text: room.status.badge.text,
        textColor: room.status.badge.textColor,
        bgColor: room.status.badge.bgColor,
        iconName: room.status.badge.iconName
      )
      .padding(.top, 10)
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 20)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.white)
    .contentShape(Rectangle())
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray100).frame(height: 1)
    }
  }
}

#Preview {
  ChatListView(viewModel: .preview())
}
