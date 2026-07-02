import SwiftUI

enum Layout {
  static let screenHorizontalPadding: CGFloat = 16
}

struct ScreenContainer<Content: View>: View {
  private let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding(.horizontal, Layout.screenHorizontalPadding)
  }
}
