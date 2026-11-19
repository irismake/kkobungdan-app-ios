import SwiftUI

struct TabPageHeader<Trailing: View>: View {
  let title: String
  /// 제목 옆 개수(예: 채팅 안읽음). nil 이면 숨긴다.
  var count: Int?
  /// 헤더 우측 액션(예: 알림 버튼). 헤더 높이에 영향을 주지 않도록 세로로 겹쳐 배치한다.
  @ViewBuilder var trailing: () -> Trailing

  var body: some View {
    HStack {
      Text(title)
        .textStyle(.heading1)
        .foregroundColor(Color.gray900)
      if let count {
        Text("\(count)")
          .textStyle(.heading5)
          .foregroundColor(Color.indigo500)
          .padding(.leading, 8)
      }
      Spacer()
      trailing()
        .frame(height: 28)
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 12)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }
}

extension TabPageHeader where Trailing == EmptyView {
  init(title: String, count: Int? = nil) {
    self.init(title: title, count: count) { EmptyView() }
  }
}

#Preview {
  VStack(spacing: 0) {
    TabPageHeader(title: "홈") {
      NotificationBellButton(unreadCount: 3) {}
    }
    TabPageHeader(title: "프로필")
  }
}
