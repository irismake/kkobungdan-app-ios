import SwiftUI

/// 탭 헤더 우측 알림(벨) 버튼. 안읽음이 있으면 뱃지를 겹쳐 표시한다.
struct NotificationBellButton: View {
  var unreadCount: Int = 0
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Image("icon_notification")
        .renderingMode(.template)
        .resizable()
        .scaledToFit()
        .frame(width: 24, height: 24)
        .foregroundColor(Color.indigo500)
        .overlay {
          if unreadCount > 0 {
            CountBadge(count: unreadCount)
              .offset(x: 8, y: -8)
          }
        }
        // 터치 영역 44x44 확보. 아이콘 우측 끝은 헤더 패딩(24)에 맞춘다.
        .frame(width: 44, height: 44)
        .contentShape(Rectangle())
    }
    .buttonStyle(.plain)
    .padding(.trailing, -10)
  }
}

#Preview {
  NotificationBellButton(unreadCount: 3) {}
}
