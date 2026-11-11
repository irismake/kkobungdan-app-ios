import SwiftUI

/// 메인 탭의 '채팅' 세그먼트.
// TODO: 채팅 API 연동 시 목록·안읽음 개수 구현
struct ChatListView: View {
  var body: some View {
    VStack(spacing: 0) {
      TabPageHeader(title: "채팅")
      ScrollView {
        Text("아직 채팅이 없어요.")
          .textStyle(.body3)
          .foregroundColor(Color.gray500)
          .padding(.top, 40)
          .frame(maxWidth: .infinity)
      }
      .background(Color.gray000)
    }
    .background(Color.gray000)
  }
}

#Preview {
  ChatListView()
}
