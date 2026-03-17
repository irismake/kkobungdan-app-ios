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
    ZStack {
      Color.white
        .ignoresSafeArea()

      content
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.horizontal, Layout.screenHorizontalPadding)
    }
  }
}
