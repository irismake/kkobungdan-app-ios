import SwiftUI

struct NotificationView: View {
  @State private var viewModel: NotificationViewModel

  init(viewModel: NotificationViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "알림")
      ScrollView {
        LazyVStack(spacing: 0) {
          if viewModel.isLoading, viewModel.notifications.isEmpty {
            ProgressView()
              .padding(.top, 40)
          } else if let errorMessage = viewModel.errorMessage, viewModel.notifications.isEmpty {
            Text(errorMessage)
              .textStyle(.body3)
              .foregroundColor(Color.rose500)
              .padding(.top, 40)
          } else {
            ForEach(viewModel.notifications) { item in
              NotificationItemView(
                title: item.title,
                message: item.body,
                timeString: ProposalFormatter.relativeTimeString(item.createdAt),
                isRead: item.isRead
              )
              .onTapGesture {
                guard !item.isRead else {
                  return
                }
                Task { await viewModel.markAsRead(id: item.id) }
              }
              .onAppear {
                Task { await viewModel.loadMoreIfNeeded(currentItem: item) }
              }
            }

            if viewModel.isLoadingMore {
              ProgressView()
                .padding(.vertical, 16)
            }
          }
        }
      }
      .background(Color.gray000)
    }
    .background(Color.gray000)
    .task {
      await viewModel.load()
    }
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
