import SwiftUI

struct NotificationView: View {
  @State private var viewModel: NotificationViewModel

  /// 딥링크 있는 알림 셀 탭 시 호출. 푸시 배너 탭과 동일한 라우팅을 태운다.
  var onSelect: (PushPayload) -> Void = { _ in }

  init(
    viewModel: NotificationViewModel,
    onSelect: @escaping (PushPayload) -> Void = { _ in }
  ) {
    _viewModel = State(initialValue: viewModel)
    self.onSelect = onSelect
  }

  var body: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "알림")
      ScrollView {
        LazyVStack(spacing: 0) {
          if viewModel.isLoading, viewModel.notifications.isEmpty {
            ProgressView()
              .padding(.top, 40)
              .frame(maxWidth: .infinity)
          } else if viewModel.notifications.isEmpty {
            Text("아직 알림이 없어요.")
              .textStyle(.body3)
              .foregroundColor(Color.gray500)
              .padding(.top, 40)
              .frame(maxWidth: .infinity)
          } else {
            ForEach(viewModel.notifications) { item in
              NotificationItemView(
                title: item.title,
                message: item.body,
                timeString: DisplayFormatter.relativeTimeString(item.createdAt),
                isRead: item.isRead
              )
              .onTapGesture {
                if !item.isRead {
                  Task { await viewModel.markAsRead(id: item.id) }
                }
                if let deepLink = item.deepLink {
                  onSelect(deepLink)
                }
              }
              .onAppear {
                Task { await viewModel.loadMoreIfNeeded(currentItem: item) }
              }
            }

            if viewModel.isLoadingMore {
              ProgressView()
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity)
            }
          }
        }
      }
      .background(Color.gray000)
      .refreshable {
        await viewModel.syncNotifications()
      }
    }
    .background(Color.gray000)
    .task(id: PushRouteStore.shared.foregroundPushCount) {
      await viewModel.syncNotifications()
    }
    .errorToast($viewModel.errorMessage)
  }
}

struct NotificationItemView: View {
  let title: String
  let message: String
  let timeString: String
  let isRead: Bool

  private var backgroundColor: Color {
    isRead ? .white : .blue000
  }

  private var borderColor: Color {
    isRead ? .gray200 : .blue200
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 10) {
        Text(title)
          .textStyle(.title2)
          .foregroundColor(Color.gray900)
          .frame(maxWidth: .infinity, alignment: .leading)

        if !isRead {
          Circle()
            .fill(Color.blue600.opacity(0.8))
            .frame(width: 8, height: 8)
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(message)
          .textStyle(.body3)
          .foregroundColor(Color.gray700)
          .fixedSize(horizontal: false, vertical: true)

        Text(timeString)
          .textStyle(.caption2)
          .kerning(-0.1)
          .foregroundColor(Color.gray500)
      }
    }
    .padding(16)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(backgroundColor)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(borderColor)
        .frame(height: 1)
    }
  }
}

#Preview {
  NotificationView(viewModel: .preview())
}
