import SwiftUI

struct NotificationItem: Identifiable {
  let id: UUID = .init()
  let title: String
  let body: String
  let timeString: String
  let isRead: Bool
}

struct NotificationView: View {
  // TODO: ViewModel에서 실제 데이터로 교체
  private let items: [NotificationItem] = [
    NotificationItem(
      title: "게시물이 등록됐어요! 🎉",
      body: "웨이팅비 입금이 확인됐어요. 지금 바로 지원자를 기다려보세요!",
      timeString: "20분 전",
      isRead: false
    ),
    NotificationItem(
      title: "아직 만남 확인이 안 됐어요 👋",
      body: "상대방은 이미 만남을 확인했어요. 앱에서 '만났어요' 버튼을 눌러주시면 정산이 바로 진행돼요!",
      timeString: "1일 전",
      isRead: false
    ),
    NotificationItem(
      title: "채팅방이 열렸어요! 💬",
      body: "카카오톡 단체 채팅방이 개설됐어요. 입장 코드 [XXXXXX]로 지금 바로 입장해보세요!",
      timeString: "1주 전",
      isRead: true
    ),
    NotificationItem(
      title: "웨이팅 완료! 수고하셨어요 🎊",
      body: "양측 만남이 모두 확인됐어요. 성공적으로 웨이팅이 완료됐습니다!",
      timeString: "2026. 04. 05 오후 12:16",
      isRead: true
    ),
    NotificationItem(
      title: "게시물이 등록됐어요! 🎉",
      body: "웨이팅비 입금이 확인됐어요. 지금 바로 지원자를 기다려보세요!",
      timeString: "2025. 11. 28 오후 12:16",
      isRead: false
    )
  ]

  var body: some View {
    VStack(spacing: 0) {
      header
      ScrollView {
        LazyVStack(spacing: 0) {
          ForEach(items) { item in
            NotificationItemView(item: item)
          }
        }
      }
      .background(Color.gray000)
    }
    .background(Color.gray000)
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
  let item: NotificationItem

  private var backgroundColor: Color {
    item.isRead ? .white : .blue000
  }

  private var borderColor: Color {
    item.isRead ? .gray200 : .blue200
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(spacing: 10) {
        Text(item.title)
          .font(.custom("Pretendard-SemiBold", size: 14))
          .kerning(-0.4)
          .appLineHeight(20, fontName: "Pretendard-SemiBold", fontSize: 14)
          .foregroundColor(Color.gray900)
          .frame(maxWidth: .infinity, alignment: .leading)

        if !item.isRead {
          Circle()
            .fill(Color.blue600.opacity(0.8))
            .frame(width: 8, height: 8)
        }
      }

      VStack(alignment: .leading, spacing: 4) {
        Text(item.body)
          .font(.custom("Pretendard-Regular", size: 14))
          .kerning(-0.1)
          .appLineHeight(20, fontName: "Pretendard-Regular", fontSize: 14)
          .foregroundColor(Color.gray700)
          .fixedSize(horizontal: false, vertical: true)

        Text(item.timeString)
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
  NotificationView()
}
