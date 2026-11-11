import SwiftUI

/// 아이콘 우상단에 겹쳐 표시하는 안읽음 개수 뱃지. 10 이상은 "9+" 로 표시한다.
struct CountBadge: View {
  let count: Int

  var body: some View {
    Text(count > 9 ? "9+" : "\(count)")
      .textStyle(.badge1)
      .foregroundColor(Color.indigo000)
      .frame(width: 16, height: 16)
      .background(Circle().fill(Color.indigo500))
  }
}

#Preview {
  HStack {
    CountBadge(count: 3)
    CountBadge(count: 12)
  }
}
