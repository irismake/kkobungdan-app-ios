import SwiftUI

struct Gap: View {
  private let width: CGFloat?
  private let height: CGFloat?

  private init(width: CGFloat? = nil, height: CGFloat? = nil) {
    self.width = width
    self.height = height
  }

  static func v(_ height: CGFloat) -> Gap {
    Gap(height: height)
  }

  static func h(_ width: CGFloat) -> Gap {
    Gap(width: width)
  }

  var body: some View {
    Color.clear
      .frame(width: width, height: height)
  }
}
