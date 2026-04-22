import SwiftUI

struct NotificationView: View {
  @State private var viewModel: NotificationViewModel

  init(viewModel: NotificationViewModel) {
    _viewModel = State(initialValue: viewModel)
  }

  var body: some View {
    VStack(spacing: 0) {
      header
      ScrollView {
        LazyVStack(spacing: 0) {
          if viewModel.isLoading, viewModel.notifications.isEmpty {
            ProgressView()
              .padding(.top, 40)
          } else if let errorMessage = viewModel.errorMessage, viewModel.notifications.isEmpty {
            Text(errorMessage)
              .foregroundColor(Color.rose500)
              .padding(.top, 40)
          } else {
            ForEach(viewModel.notifications) { item in
              NotificationItemView(
                title: item.title,
                message: item.body,
                timeString: ProposalDisplay.relativeTimeString(item.createdAt),
                isRead: item.isRead
              )
              .onTapGesture {
                guard !item.isRead else {
                  return
                }
                Task { await viewModel.markAsRead(id: item.id) }
              }
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

  private var header: some View {
    HStack {
      Text("알림")
        .font(.custom("Pretendard-SemiBold", size: 24))
        .kerning(-0.4)
        .appLineHeight(28, fontName: "Pretendard-SemiBold", fontSize: 24)
        .foregroundColor(Color.gray900)
      Spacer()
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 12)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.gray200)
        .frame(height: 1)
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
          .font(.custom("Pretendard-SemiBold", size: 14))
          .kerning(-0.4)
          .appLineHeight(20, fontName: "Pretendard-SemiBold", fontSize: 14)
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
          .font(.custom("Pretendard-Regular", size: 14))
          .kerning(-0.1)
          .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 14)
          .foregroundColor(Color.gray700)
          .fixedSize(horizontal: false, vertical: true)

        Text(timeString)
          .font(.custom("Pretendard-Regular", size: 12))
          .kerning(-0.1)
          .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 12)
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
