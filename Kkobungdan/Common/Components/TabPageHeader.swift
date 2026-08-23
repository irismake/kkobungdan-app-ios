import SwiftUI

struct TabPageHeader: View {
  let title: String

  var body: some View {
    HStack {
      Text(title)
        .textStyle(.heading1)
        .foregroundColor(Color.gray900)
      Spacer()
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 12)
    .background(Color.white)
    .overlay(alignment: .bottom) {
      Rectangle().fill(Color.gray200).frame(height: 1)
    }
  }
}

#Preview {
  TabPageHeader(title: "홈")
}
